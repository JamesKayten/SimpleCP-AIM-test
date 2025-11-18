import SwiftUI

struct LoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
