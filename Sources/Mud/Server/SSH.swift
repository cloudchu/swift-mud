//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/12.
//

import Foundation
import NIO
import NIOSSH

enum SSHServerError: Error {
    case invalidDataType
    case invalidChannelType
    case alreadyListening
    case notListening
}

final class ErrorHandler: ChannelInboundHandler {
    typealias InboundIn = Any
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error in pipeline: \(error)")
        context.close(promise: nil)
    }
}

final class NoLoginDelegate: NIOSSHServerUserAuthenticationDelegate {
    var supportedAuthenticationMethods: NIOSSHAvailableUserAuthenticationMethods {
        .all
    }
    
    func requestReceived(request: NIOSSHUserAuthenticationRequest, responsePromise: EventLoopPromise<NIOSSHUserAuthenticationOutcome>) {
        responsePromise.succeed(.success)
        
    }
}

final class MUDGlobalRequestDelegate: GlobalRequestDelegate {
    
}

func sshChildChannelInitializer(_ channel: Channel, _ channelType: SSHChannelType) -> EventLoopFuture<Void> {
    switch channelType {
    case .session:
        return channel.pipeline.addHandlers([BackPressureHandler(), SessionHandler(), VerbHandler(), ParseHandler(),ResponseHandler()])
    default:
        print("\(channelType) connections are not supported. Only session channels are supported.")
        return channel.eventLoop.makeFailedFuture(SSHServerError.invalidChannelType)
    }
}

extension SSHChannelData {
    init(byteBuffer: ByteBuffer) {
        let ioData = IOData.byteBuffer(byteBuffer)
        self.init(type: .channel, data: ioData)
    }
}
