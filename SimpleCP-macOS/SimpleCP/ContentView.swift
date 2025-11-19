import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "doc.on.clipboard")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("SimpleCP Menu Bar App")
                .font(.headline)
            Text("This app runs in the menu bar. Look for the clipboard icon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    ContentView()
}