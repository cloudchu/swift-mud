//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO

final class ResponseHandler: ChannelInboundHandler {
    typealias InboundIn = [MudResponse]
    typealias InboundOut = ByteBuffer
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        logger.trace("\(self) \(#function)")
        
        print("response read")
        
        let responses = self.unwrapInboundIn(data)
        
        responses.forEach{ response in
            
        //        let greenString = "\u{1B}[32m" + "[Session ID: \(response.session.id) Player ID: \(response.session.playerID)]: " + response.message + "\u{1B}[0m" + "\n> "
                let greenString = "\u{1B}[32m" + response.message + "\u{1B}[0m" + "\n> "
                
                let outBuff = context.channel.allocator.buffer(string: greenString)
                
                //context.writeAndFlush(wrapInboundOut(outBuff), promise: nil)
            
            if let session = response.session as? MudSession {
                print("response write to client")
                session.channel.writeAndFlush(wrapInboundOut(outBuff), promise: nil)
                
                // Update the session, because we might now have a plyer i or any other settings changed from commands.
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
