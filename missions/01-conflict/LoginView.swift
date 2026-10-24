import SwiftUI

struct LoginView: View {
    let title = "Sign in"

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.largeTitle)
            Button("다음") {}
        }
        .padding()
    }
}
