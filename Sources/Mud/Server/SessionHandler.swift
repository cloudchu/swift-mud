//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO
import NIOSSH

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
    typealias InboundIn = SSHChannelData
    typealias InboundOut = TextCommand
    typealias OutboundOut = SSHChannelData
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        //        logger.trace("\(self) \(#function)")
        let inBuff = unwrapInboundIn(data)
        guard case .byteBuffer(let bytes) = inBuff.data else {
            fatalError("Unexpected read type")
        }
        
        guard case .channel = inBuff.type else {
            context.fireErrorCaught(SSHServerError.invalidDataType)
            return
        }
        
        let str = String(buffer: bytes)
        print("session read: \(str)")
        var session = SessionStorage.first(where: { session in
            if let session = session as? MudSession {
                return session.channel.remoteAddress == context.channel.remoteAddress
            } else {
                return false
            }
        }) as? MudSession ?? MudSession(id: UUID(), channel: context.channel, playerID: nil)

        switch str {
        case "\u{7F}": // backspace was pressed
            session = processBackspace(session, context: context)
            SessionStorage.replaceOrStoreSessionSync(session)
            
        case "\n", "\r":  // an end-of-line character, time to send the command, for ssh?
            sendCommand(session, context: context)
        default:
            session.currentString += str
            context.writeAndFlush(self.wrapOutboundOut(inBuff), promise: nil)
            SessionStorage.replaceOrStoreSessionSync(session)
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
        
        let sshWelcomeText = welcomeText.replacingOccurrences(of: "\n", with: "\n\r")
        
        let greenString = "\u{1B}[32m" + sshWelcomeText + "\u{1B}[0m" + "\n\r> "
        let outBuf = context.channel.allocator.buffer(string: greenString)
        let channelData = SSHChannelData(byteBuffer: outBuf)
        
        context.writeAndFlush(self.wrapOutboundOut(channelData), promise: nil)
    }
    
    private func sendCommand(_ session: MudSession, context: ChannelHandlerContext) {
        print("send command")
        let command = TextCommand(session: session.erasingCurrentString(), command: session.currentString)
        context.fireChannelRead(self.wrapInboundOut(command))
    }
    
    private func processBackspace(_ session: MudSession, context: ChannelHandlerContext) -> MudSession {
        print("process backspace: current string is \(session.currentString)")
        guard session.currentString.count > 0 else {
            return session
        }
        
        var updatedSession = session
        var backspaceString = "\u{1B}[1D \u{1B}[1D"
        let lastChar = session.currentString.last
        if let lastChar, !lastChar.isASCII {
            backspaceString = "\u{1B}[1D\u{1B}[1D \u{1B}[1D"
        }
        updatedSession.currentString = String(session.currentString.dropLast(1))
        let outBuff = context.channel.allocator.buffer(string: backspaceString)
        let channelData = SSHChannelData(byteBuffer: outBuff)
        context.writeAndFlush(self.wrapOutboundOut(channelData), promise: nil)
        return updatedSession
    }
}
