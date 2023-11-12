//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO

final class EchoHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        //logger.trace("\(self) \(#function)")
        
        let inBuff = self.unwrapInboundIn(data)
        let inStr = inBuff.getString(at: 0, length: inBuff.readableBytes) ?? ""
        
        print("recv msg: " + inStr)
        
        let outStr = "\u{1B}[32m" + inStr + "\u{1B}[0m"
        
        print("send msg: " + "Green string: " + outStr)

        let outBuff = context.channel.allocator.buffer(string: outStr)
        context.writeAndFlush(wrapInboundOut(outBuff), promise: nil)
    }
}
