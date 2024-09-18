import SwiftUI

struct PostView: View {
    @Binding var isPresented: Bool

    private let username = "nesbittj"
    @State private var message = "Some short sample text."
    
    var body: some View {
            VStack {
                Text(username)
                    .padding(.top, 30.0)
                TextEditor(text: $message)
                    .padding(EdgeInsets(top: 10, leading: 18, bottom: 0, trailing: 4))
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.navigationBarTrailing) {
                    SubmitButton()
                }
            }
        }

        @ViewBuilder
        func SubmitButton() -> some View {
            Button {
                ChattStore.shared.postChatt(Chatt(username: username, message: message)) {
                    ChattStore.shared.getChatts()
                }
                isPresented.toggle()
            } label: {
                Image(systemName: "paperplane")
            }
        }
    }
