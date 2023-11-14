import NIO
import Foundation
import Logging
import NIOSSH

func main() async {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    do {
        defer {
            try! group.syncShutdownGracefully()
        }
        
        let hostKey: NIOSSHPrivateKey
        
        
        if let existingKey = await SSHKey.first(where: {_ in true}) {
            hostKey = try existingKey.toNIOSSHPrivateKey()
            print("Reusing existing hostkey with id: \(existingKey.id)")
        } else {
            let newKey = SSHKey.initRandomKey()
            hostKey = try newKey.toNIOSSHPrivateKey()
            await newKey.save()
            print("Creating new hostkey with id: \(newKey.id)")
        }
        
        
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { [hostKey] channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(role: .server(.init(hostKeys: [hostKey], userAuthDelegate: NoLoginDelegate(),globalRequestDelegate: MUDGlobalRequestDelegate())), allocator: channel.allocator, inboundChildChannelInitializer: sshChildChannelInitializer(_:_:)), ErrorHandler()
                ])
            }
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
        
        
        let host = ProcessInfo.processInfo.environment["SWIFTMUD_HOSTNAME"] ?? "::1" // "localhost"
        let port = Int(ProcessInfo.processInfo.environment["SWIFTMUD_PORT"] ?? "2222") ?? 2222
        
        var logger = Logger(label: "SwiftNIOMUD")
        logger.logLevel = .trace
        
        let channel = try await bootstrap.bind(host: host, port: port).get()
        
        print("Server started successfully, listening on address: \(channel.localAddress!)")
        
        try await channel.closeFuture.get()
        
        print("Server closed.")
    } catch {
        print(error)
    }
}

let t = Task {
    await main()
}

await t.value
