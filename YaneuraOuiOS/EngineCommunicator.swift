//
//  EngineCommunicator.swift
//  YaneuraOuiOS
//
//  Created by 日高雅俊 on 2024/04/03.
//

import Foundation
import YaneuraOuiOSSPM

// やねうら王とのプロセス内通信関係のバッファ（グローバル関数にするしかない）
var yaneRecvBuffer: Data = Data()
let recvSemaphore = DispatchSemaphore(value: 1)
var yaneSendBuffer: Data = Data()
let sendSemaphore = DispatchSemaphore(value: 1)
var yaneRecvCallback: (String) -> Void = {_ in}

func usiWrite(char: Int32) -> Void {
    // 思考スレッドから呼ばれる
    // 1文字ずつくる。
    // 改行が含まれている。複数行の場合もある。
    // USIクライアント->USIサーバへの送信
    if char < 0 {
        print("usiWrite(EOF)")
        return
    }
    
    sendSemaphore.wait()
    
    if char == 0x0a {
        // end of line
        let completeBuffer = yaneSendBuffer
        yaneSendBuffer = Data()
        // 改行文字は含まない
        yaneRecvCallback(String(data: completeBuffer, encoding: .utf8)!)
    } else {
        yaneSendBuffer.append(contentsOf: [UInt8(clamping: char)])
    }
    
    sendSemaphore.signal()
}

func usiRead() -> Int32 {
    // 思考スレッドから呼ばれる
    // USIサーバ->USIクライアントへの受信
    var item: Int32 = 0
    while true {
        recvSemaphore.wait()
        if yaneRecvBuffer.count > 0 {
            item = Int32(yaneRecvBuffer[0])
            // recvBuffer = recvBuffer.dropFirst()
            // を使うと、次回のrecvBuffer[0]のアクセス時になぜかクラッシュする
            yaneRecvBuffer = Data(yaneRecvBuffer[1...])
            recvSemaphore.signal()
            break
        } else {
            recvSemaphore.signal()
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    return item
}

func stringToUnsafeMutableBufferPointer(_ s: String) -> UnsafeMutableBufferPointer<Int8> {
    let count = s.utf8CString.count
    let result: UnsafeMutableBufferPointer<Int8> = UnsafeMutableBufferPointer<Int8>.allocate(capacity: count)
    _ = result.initialize(from: s.utf8CString)
    return result
}

func startYaneuraou(recvCallback: @escaping (String) -> Void) {
    // やねうら王とのプロセス内通信準備
    // recvCallback: やねうら王からメッセージを受信したときに呼ばれる（改行を含まない1行） 例: "bestmove 7g7f"
    yaneRecvCallback = recvCallback

    // assetのnn.binを評価関数ファイルとして渡す
    guard let nnue_eval_path = Bundle.main.path(forResource: "nn", ofType: "bin") else {
        fatalError()
    }
    let nnue_eval_path_p = stringToUnsafeMutableBufferPointer(nnue_eval_path)
    
    YaneuraOuiOSSPM.yaneuraou_ios_main(usiRead, usiWrite, nnue_eval_path_p.baseAddress!)
}

func sendToYaneuraou(messageWithoutNewLine: String) -> Void {
    // やねうら王にコマンドを送る 例: "usinewgame"
    let d = (messageWithoutNewLine + "\n").data(using: .utf8)!
    recvSemaphore.wait()
    yaneRecvBuffer.append(d)
    recvSemaphore.signal()
}
