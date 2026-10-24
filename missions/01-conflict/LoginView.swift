import SwiftUI

struct LoginView: View {
    let title = "Login"

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.largeTitle)
            Button("계속하기") {}
        }
        .padding()
    }
}
