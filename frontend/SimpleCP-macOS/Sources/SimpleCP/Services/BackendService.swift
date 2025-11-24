//
//  BackendService.swift
//  SimpleCP
//
//  Manages the Python backend process lifecycle
//

import Foundation
import os.log

class BackendService: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var backendError: String?

    private var backendProcess: Process?
    private let logger = Logger(subsystem: "com.simplecp.app", category: "backend")
    private let port: Int = 8000
    private let pidFilePath = "/tmp/simplecp_backend.pid"

    init() {
        logger.info("🚀 BackendService initialized")
    }

    // MARK: - Port Management

    /// Check if the specified port is in use
    private func isPortInUse(_ port: Int) -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-t", "-i:\(port)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            return !output.isEmpty
        } catch {
            logger.error("❌ Failed to check port status: \(error.localizedDescription)")
            return false
        }
    }

    /// Kill any process using the specified port
    private func killProcessOnPort(_ port: Int) -> Bool {
        logger.info("🛑 Attempting to kill process on port \(port)")

        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "lsof -t -i:\(port) | xargs kill -9 2>/dev/null"]

        do {
            try task.run()
            task.waitUntilExit()

            // Wait a moment for the process to die
            Thread.sleep(forTimeInterval: 0.5)

            // Verify port is now free
            if !isPortInUse(port) {
                logger.info("✅ Successfully freed port \(port)")
                return true
            } else {
                logger.warning("⚠️ Port \(port) still in use after kill attempt")
                return false
            }
        } catch {
            logger.error("❌ Failed to kill process on port \(port): \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Backend Lifecycle

    /// Start the Python backend process
    func startBackend() {
        // Check if already running
        if isRunning, let process = backendProcess, process.isRunning {
            logger.info("ℹ️ Backend already running")
            return
        }

        // Check if port is in use and try to free it
        if isPortInUse(port) {
            logger.warning("⚠️ Port \(port) is already in use. Attempting to free it...")
            if !killProcessOnPort(port) {
                backendError = "Port \(port) is in use and couldn't be freed. Please run: ./kill_backend.sh"
                logger.error("❌ Failed to start backend: port conflict")
                return
            }
        }

        // Find project root and Python executable
        guard let projectRoot = findProjectRoot() else {
            backendError = "Could not find project root directory"
            logger.error("❌ Failed to find project root")
            return
        }

        let backendPath = projectRoot.appendingPathComponent("backend")
        let mainPyPath = backendPath.appendingPathComponent("main.py")

        // Verify backend files exist
        guard FileManager.default.fileExists(atPath: mainPyPath.path) else {
            backendError = "Backend not found at: \(mainPyPath.path)"
            logger.error("❌ Backend main.py not found")
            return
        }

        // Find Python 3 executable
        guard let python3Path = findPython3() else {
            backendError = "Python 3 not found. Please install Python 3."
            logger.error("❌ Python 3 not found")
            return
        }

        logger.info("🚀 Starting backend...")
        logger.info("   Python: \(python3Path)")
        logger.info("   Backend: \(mainPyPath.path)")
        logger.info("   Working dir: \(backendPath.path)")

        // Create and configure process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: python3Path)
        process.arguments = [mainPyPath.path]
        process.currentDirectoryURL = backendPath

        // Set up environment
        var environment = ProcessInfo.processInfo.environment
        environment["PYTHONUNBUFFERED"] = "1"
        process.environment = environment

        // Capture output for debugging
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Monitor output
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                self?.logger.debug("📋 Backend stdout: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                self?.logger.error("⚠️ Backend stderr: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }

        // Handle process termination
        process.terminationHandler = { [weak self] process in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRunning = false
                self.backendProcess = nil
                self.logger.info("🛑 Backend process terminated (exit code: \(process.terminationStatus))")

                // Clean up PID file
                try? FileManager.default.removeItem(atPath: self.pidFilePath)
            }
        }

        // Launch the process
        do {
            try process.run()
            backendProcess = process

            // Write PID file
            let pid = process.processIdentifier
            try? "\(pid)".write(toFile: pidFilePath, atomically: true, encoding: .utf8)

            // Wait a moment for backend to start
            Thread.sleep(forTimeInterval: 1.0)

            // Verify backend is responding
            Task {
                await verifyBackendHealth()
            }

            DispatchQueue.main.async {
                self.isRunning = true
                self.backendError = nil
                self.logger.info("✅ Backend started successfully (PID: \(pid))")
            }
        } catch {
            backendError = "Failed to start backend: \(error.localizedDescription)"
            logger.error("❌ Failed to launch backend process: \(error.localizedDescription)")
        }
    }

    /// Stop the backend process
    func stopBackend() {
        guard let process = backendProcess, process.isRunning else {
            logger.info("ℹ️ Backend not running")
            isRunning = false
            return
        }

        logger.info("🛑 Stopping backend...")

        // Try graceful termination first
        process.terminate()

        // Wait up to 2 seconds for graceful shutdown
        let deadline = Date().addingTimeInterval(2.0)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }

        // Force kill if still running
        if process.isRunning {
            logger.warning("⚠️ Backend didn't stop gracefully, force killing...")
            process.interrupt()
            Thread.sleep(forTimeInterval: 0.2)

            // Last resort: kill -9 via PID
            if process.isRunning {
                let pid = process.processIdentifier
                kill(pid, SIGKILL)
                logger.warning("⚠️ Sent SIGKILL to backend process")
            }
        }

        // Clean up
        backendProcess = nil
        isRunning = false

        // Clean up PID file
        try? FileManager.default.removeItem(atPath: pidFilePath)

        // Make sure port is freed
        if isPortInUse(port) {
            _ = killProcessOnPort(port)
        }

        logger.info("✅ Backend stopped")
    }

    /// Restart the backend
    func restartBackend() {
        logger.info("🔄 Restarting backend...")
        stopBackend()
        Thread.sleep(forTimeInterval: 0.5)
        startBackend()
    }

    // MARK: - Health Check

    private func verifyBackendHealth() async {
        do {
            let url = URL(string: "http://localhost:\(port)/health")!
            let (_, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                logger.info("✅ Backend health check passed")
            } else {
                logger.warning("⚠️ Backend health check returned unexpected response")
            }
        } catch {
            logger.error("❌ Backend health check failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.backendError = "Backend started but health check failed"
            }
        }
    }

    // MARK: - Utility Functions

    /// Find the project root directory
    private func findProjectRoot() -> URL? {
        // Try to find SimpleCP project root
        // Start from bundle and walk up looking for backend folder
        var currentURL = Bundle.main.bundleURL

        for _ in 0..<10 {  // Limit search depth
            let backendURL = currentURL.appendingPathComponent("backend")
            if FileManager.default.fileExists(atPath: backendURL.path) {
                return currentURL
            }
            currentURL = currentURL.deletingLastPathComponent()
        }

        // Fallback: try common development paths
        let possiblePaths = [
            "/Volumes/User_Smallfavor/Users/Smallfavor/clipboard_manager",
            FileManager.default.currentDirectoryPath,
            ProcessInfo.processInfo.environment["PROJECT_DIR"] ?? ""
        ]

        for path in possiblePaths {
            let url = URL(fileURLWithPath: path)
            let backendURL = url.appendingPathComponent("backend")
            if FileManager.default.fileExists(atPath: backendURL.path) {
                return url
            }
        }

        return nil
    }

    /// Find Python 3 executable
    private func findPython3() -> String? {
        let possiblePaths = [
            "/usr/bin/python3",
            "/usr/local/bin/python3",
            "/opt/homebrew/bin/python3",
            "/opt/local/bin/python3"
        ]

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        // Try using 'which' command
        let task = Process()
        task.launchPath = "/usr/bin/which"
        task.arguments = ["python3"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !path.isEmpty {
                    return path
                }
            }
        } catch {
            logger.error("❌ Failed to find python3: \(error.localizedDescription)")
        }

        return nil
    }

    deinit {
        stopBackend()
    }
}
