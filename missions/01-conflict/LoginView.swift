import SwiftUI

struct LoginView: View {
    let title = "로그인"

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.largeTitle)
            Button("다음") {}
        }
        .padding()
    }
}
