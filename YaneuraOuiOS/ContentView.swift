import SwiftUI
import YaneuraOuiOSSPM

struct ContentView: View {
    @State private var messagesFromEngine: [String] = []

    var body: some View {
        VStack {
            Text("YaneuraOu iOS")
            Button(action: {
                startYaneuraou(recvCallback: { messageFromYane in
                    DispatchQueue.main.async {
                        messagesFromEngine.append(messageFromYane)
                    }
                })
                sendToYaneuraou(messageWithoutNewLine: "usi")
                sendToYaneuraou(messageWithoutNewLine: "isready")
                sendToYaneuraou(messageWithoutNewLine: "usinewgame")
                sendToYaneuraou(messageWithoutNewLine: "position startpos")
                sendToYaneuraou(messageWithoutNewLine: "go movetime 10000")
            }) {
                Text("Run")
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messagesFromEngine, id: \.self) { message in
                        Text(message)
                            .padding(.bottom, 2)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
