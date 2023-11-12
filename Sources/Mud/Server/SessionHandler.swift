//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO

struct MudSession: Session {
    let id: UUID
    let channel: Channel
    var playerID: UUID?
    var shouldClose: Bool = false
    var currentString: String = ""
}

struct TextCommand {
    let session: MudSession
    let command: String
}


final class SessionHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = TextCommand
    typealias OutboundOut = ByteBuffer
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        //        logger.trace("\(self) \(#function)")
        print("session read")
        
        let inBuff = unwrapInboundIn(data)
        let inStr = inBuff.getString(at: 0, length: inBuff.readableBytes) ?? ""
        
        //        let session = Session(id: UUID(), channel: context.channel, playerID: nil)
        //        let session = SessionStorage.first(where: {$0.channel.remoteAddress == context.channel.remoteAddress}) ??
        //        Session(id: UUID(), channel: context.channel, playerID: nil)
        
        var session = SessionStorage.first(where: { session in
            if let session = session as? MudSession {
                return session.channel.remoteAddress == context.channel.remoteAddress
            } else {
                return false
            }
        }) as? MudSession ?? MudSession(id: UUID(), channel: context.channel, playerID: nil)
        
        switch inStr {
        case "\u{7F}": // backspace was pressed
            session = processBackspace(session, context: context)
            SessionStorage.replaceOrStoreSessionSync(session)
            
        case "\n", "\r":  // an end-of-line character, time to send the command, for ssh?
            sendCommand(session, context: context)
        default:
//            session.currentString += inStr
//            context.writeAndFlush(self.wrapOutboundOut(inBuff), promise: nil)
//            SessionStorage.replaceOrStoreSessionSync(session)
            // for telnet
            session.currentString = inStr.trimmingCharacters(in: .whitespacesAndNewlines)
            sendCommand(session, context: context)
        }
    }
    
    func channelActive(context: ChannelHandlerContext) {
        print("session active")
        
        let welcomeText = """
        Welcome to Swift Mud!
        Hope you enjoy your stay.
        Please user "CREATE_USER" <username> <password> to begin.
        You car leave by using the "CLOSE" command.
        For a list of commands, use 'HELP'.
        """
        
        let greenString = "\u{1B}[32m" + welcomeText + "\u{1B}[0m" + "\n> "
        
        let outBuf = context.channel.allocator.buffer(string: greenString)
      //  print("session write")
//        context.writeAndFlush(NIOAny(outBuf), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(outBuf), promise: nil)
    }
    
    private func sendCommand(_ session: MudSession, context: ChannelHandlerContext) {
        print("send command")
        let command = TextCommand(session: session.erasingCurrentString(), command: session.currentString)
        context.fireChannelRead(self.wrapInboundOut(command))
    }
    
    private func processBackspace(_ session: MudSession, context: ChannelHandlerContext) -> MudSession {
        print("process backspace")
        guard session.currentString.count > 0 else {
            return session
        }
        
        var updatedSession = session
        updatedSession.currentString = String(session.currentString.dropLast(1))
        let backspaceString = "\u{1B}[1D \u{1B}[1D"
        let outBuff = context.channel.allocator.buffer(string: backspaceString)
        context.writeAndFlush(self.wrapOutboundOut(outBuff), promise: nil)
        return updatedSession
    }
}
