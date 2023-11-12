import NIO
import Foundation
import Logging

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    // Pipeline
    // BckPressreHandler(ByteBuffer) - > SessionHandler(TextCommand) -> VerbHandler(VerbCommand
    // ParseHandler(MudResponse) -> ResponseHandler(ByteBuffer)
    .childChannelInitializer({channel in
//        channel.pipeline.addHandlers([BackPressureHandler(), EchoHandler()])
        channel.pipeline.addHandlers([BackPressureHandler(), SessionHandler(), VerbHandler(), ParseHandler(), ResponseHandler()])
    })
    .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
    .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

let host = ProcessInfo.processInfo.environment["SWIFTMUD_HOSTNAME"] ?? "::1" // "localhost"
let port = Int(ProcessInfo.processInfo.environment["SWIFTMUD_PORT"] ?? "8888") ?? 8888

var logger = Logger(label: "SwiftNIOMUD")
logger.logLevel = .trace

let channel = try bootstrap.bind(host: host, port: port).wait()

print("Server started successfully, listen on address: \(channel.localAddress!)")

try channel.closeFuture.wait()

print("Server closed.")
