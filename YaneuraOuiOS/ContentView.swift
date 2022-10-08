//
//  ContentView.swift
//  YaneuraOuiOS
//
//  Created by Masatoshi Hidaka on 2022/10/08.
//

import SwiftUI
import YaneuraOuiOSSPM

struct ContentView: View {
    @State private var usiHost = "127.0.0.1"
    var body: some View {
        VStack {
            Text("YaneuraOu iOS")
            HStack {
                Text("USI Host IP:")
                TextField("", text: $usiHost)
            }.padding()
            Button(action: {
                let host = usiHost
                let count = host.utf8CString.count
                let result: UnsafeMutableBufferPointer<Int8> = UnsafeMutableBufferPointer<Int8>.allocate(capacity: count)
                _ = result.initialize(from: host.utf8CString)
                print("yaneuraou_ios_main", YaneuraOuiOSSPM.yaneuraou_ios_main(result.baseAddress!, 8090))
            }) {
                Text("Run")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
