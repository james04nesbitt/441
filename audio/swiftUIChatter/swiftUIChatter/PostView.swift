import SwiftUI

struct PostView: View {
    @Binding var isPresented: Bool
    
    @Environment(AudioPlayer.self) private var audioPlayer
    @State private var isPresenting = false
    
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
            ToolbarItem(placement: .bottomBar) {
                AudioButton(isPresenting: $isPresenting)
            }
        }
        .fullScreenCover(isPresented: $isPresenting) {
            AudioView(isPresented: $isPresenting, autoPlay: false)
        }
        .onAppear {
            audioPlayer.setupRecorder()
        }
        .onTapGesture {
            // dismiss virtual keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button {
            ChattStore.shared.postChatt(Chatt(username: username, message: message, audio: audioPlayer.audio?.base64EncodedString())) {
                ChattStore.shared.getChatts()
            }
            isPresented.toggle()
        } label: {
            Image(systemName: "paperplane")
        }
    }
}

struct AudioButton: View {
    @Binding var isPresenting: Bool
    @Environment(AudioPlayer.self) private var audioPlayer

    var body: some View {
        Button {
            isPresenting.toggle()
        } label: {
            if let _ = audioPlayer.audio {
                Image(systemName: "mic.fill").padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)).scaleEffect(1.5).foregroundColor(Color(.systemRed))
            } else {
                Image(systemName: "mic").padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)).scaleEffect(1.5).foregroundColor(Color(.systemGreen))
            }
        }
    }
}
