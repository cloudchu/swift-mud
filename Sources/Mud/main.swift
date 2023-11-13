import NIO
import Foundation
import Logging
import NIOSSH

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

defer {
    try! group.syncShutdownGracefully()
}

let fixedKeyBase64 = "UIL9M6Utw/jiupzqq6F8EW4qySxAbgDS+wT7/RIjkJ4="
let fixedKeyData = Data(base64Encoded: fixedKeyBase64)!
let hostKey = NIOSSHPrivateKey(ed25519Key: try! .init(rawRepresentation: fixedKeyData))

let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
 
    // Pipeline
    // BckPressreHandler(ByteBuffer) - > SessionHandler(TextCommand) -> VerbHandler(VerbCommand
    // ParseHandler(MudResponse) -> ResponseHandler(ByteBuffer)
//    .childChannelInitializer({channel in
////        channel.pipeline.addHandlers([BackPressureHandler(), EchoHandler()])
//        channel.pipeline.addHandlers([BackPressureHandler(), SessionHandler(), VerbHandler(), ParseHandler(), ResponseHandler()])
//    })

    .childChannelInitializer { channel in
        channel.pipeline.addHandlers([
            NIOSSHHandler(role: .server(.init(hostKeys: [hostKey], userAuthDelegate: NoLoginDelegate(),globalRequestDelegate: MUDGlobalRequestDelegate())), allocator: channel.allocator, inboundChildChannelInitializer: sshChildChannelInitializer(_:_:)), ErrorHandler()
        ])
    }
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
//    .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
//    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
//    .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

let host = ProcessInfo.processInfo.environment["SWIFTMUD_HOSTNAME"] ?? "::1" // "localhost"
let port = Int(ProcessInfo.processInfo.environment["SWIFTMUD_PORT"] ?? "2222") ?? 2222

var logger = Logger(label: "SwiftNIOMUD")
logger.logLevel = .trace

let channel = try bootstrap.bind(host: host, port: port).wait()

print("Server started successfully, listening on address: \(channel.localAddress!)")

try channel.closeFuture.wait()

print("Server closed.")
