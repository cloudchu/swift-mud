//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation
import NIO


final class ParseHandler: ChannelInboundHandler {
    typealias InboundIn = MudCommand
    typealias InboundOut = [MudResponse]
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("parse read")
        
        let promise = context.eventLoop.makePromise(of: Void.self)
        let mudCommand = self.unwrapInboundIn(data)
        
        print("command: \(mudCommand)")
        // `Context` does not conform to `@Sendable`, but `EventLoop` does,
        // so we pass only the EventLoop and a reference to the `fireChannelRead` function.
        let eventLoop = context.eventLoop
        let fireChannelRead = context.fireChannelRead
        
        promise.completeWithTask{
            let response = await self.createMudResponse(mudCommand: mudCommand)
            eventLoop.execute {
                fireChannelRead(self.wrapInboundOut(response))
            }
        }
        
//        if #available(macOS 10.15, *) {
//            Task {
//                logger.trace("\(self) \(#function)")
//                
//                let verbCommand = unwrapInboundIn(data)
//                let response = await createMudResponse(verbCommand: verbCommand)
//                
//                context.eventLoop.execute {
//                    context.fireChannelRead(self.wrapInboundOut(response))
//                }
//
//            }
//        }
//        else {
//            // Fallback on earlier versions
//        }
        
    }
    
//    private func createMudResponse(verbCommand: VerbCommand) async -> [MudResponse] {
//        var updatedSession = verbCommand.session
//        
//        let response: [MudResponse]
//        
//        guard !verbCommand.verb.requiresLogin || updatedSession.playerID != nil  else {
//            return  [MudResponse(session: updatedSession, message: "You need to be logged in to use this command")]
//        }
//        
//        switch verbCommand.verb {
//        case .close:
//            updatedSession.shouldClose = true
//            response = [MudResponse(session: updatedSession, message: "Good Bye!")]
//        
//        case .createUser(let username, let password):
//            response = await createUser(session: updatedSession, username: username, password: password)
//        
//        case .login(let username, let password):
////            do {
////                let existingUser = try await User.login(username: username, password: password)
////                updatedSession.playerID = existingUser.id
////                response = [MudResponse(session: updatedSession, message: "Welcome back, \(existingUser.username)!")]
////            } catch {
////                response = [MudResponse(session: updatedSession, message: "Error logging in user: \(error)")]
////            }
//            response = await login(session: updatedSession, username: username, password: password)
//        
//        case .look:
//            response = await look(session: updatedSession)
//        
//        case .go(let direction):
//            response = await go(session: updatedSession, direction: direction)
//            
//        case .say(let sentence):
//            response = await sayMessage(session: updatedSession, sentence: sentence)
//            
//        case .whisper(let targetUserName, let message):
//            response = await whisperMessage(to: targetUserName, message: message, session: updatedSession)
//            
//        case .illegal:
//            response = [MudResponse(session: updatedSession, message: "This is not a well formed sentence.")]
//        case .empty:
//            response = [MudResponse(session: updatedSession, message: "\n")]
//        default:
//            response = [MudResponse(session: updatedSession, message: "Command not implemented yes.")]
//        }
//        
//        return response
//    }
    
    private func createMudResponse(mudCommand: MudCommand) async -> [MudResponse] {
        guard !mudCommand.requiresLogin || mudCommand.session.playerID != nil else {
            return [MudResponse(session: mudCommand.session, message: "You need to be logged in to use this command.")]
        }
        
        return await mudCommand.execute()
    }
}

