//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO
import NIOSSH

final class ResponseHandler: ChannelInboundHandler {
    typealias InboundIn = [MudResponse]
    typealias InboundOut = SSHChannelData
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        logger.trace("\(self) \(#function)")
        
        print("response read")
        
        let responses = self.unwrapInboundIn(data)
        
        responses.forEach{ response in
            let greenString = "\n\u{1B}[32m" + response.message + "\u{1B}[0m" + "\n> "
            let sshGreenString = greenString.replacingOccurrences(of: "\n", with: "\r\n")
            let outBuff = context.channel.allocator.buffer(string: sshGreenString)
            if let session = response.session as? MudSession {
                let channelData = SSHChannelData(byteBuffer: outBuff)
                session.channel.writeAndFlush(self.wrapInboundOut(channelData), promise: nil)
                    // Update the session, because we might now have a player id or any other settings changed from commands.
                SessionStorage.replaceOrStoreSessionSync(response.session)
                if response.session.shouldClose {
                    print("Closing session: \(response.session)")
                    SessionStorage.deleteSession(response.session)
                    _ = context.close()
                }
            }
        }
    }
}
