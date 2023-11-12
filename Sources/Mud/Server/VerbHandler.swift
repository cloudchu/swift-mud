//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO

//struct VerbCommand {
//    let session: Session
//    let verb: Verb
//}

final class VerbHandler: ChannelInboundHandler {
    static let commandFactory = MudCommandFactory()
    
    typealias InboundIn = TextCommand
    typealias InboundOut = MudCommand
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        logger.trace("\(self) \(#function)")
        print("verb read")
        
        let textCommand = unwrapInboundIn(data)
        
        let mudCommand = Self.commandFactory.createMudcommand(from: textCommand.command, session: textCommand.session)
        
        context.fireChannelRead(wrapInboundOut(mudCommand))
    }
}

