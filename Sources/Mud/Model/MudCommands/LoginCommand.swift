//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct LoginCommand: MudCommand {
    static var token = "login"
    static var expectedArgumentCount: Int = 2
    static let requiresLogin: Bool = false
    
    
    let session: Session
    let username: String
    let password: String
    
    static func create(_ arguments: [String], session: Session) -> LoginCommand? {
        guard arguments.count >= expectedArgumentCount else {
            return nil
        }
        
        return LoginCommand(session: session, username: arguments[0], password: arguments[1])
    }
    
    func execute() async -> [MudResponse] {
        var updatedSession = session
        let response: MudResponse
        
        var notifications = [MudResponse] ()
        
        do {
            let existingUser = try await User.login(username: username, password: password)
            updatedSession.playerID = existingUser.id
            response = MudResponse(session: updatedSession, message: "Welcome back, \(existingUser.username)!")
            if existingUser.currentRoomID != nil {
                notifications = await sendMessageToOtherPlayersInRoom(message: "\(existingUser.username) entered the room.", player: existingUser)
            }
        } catch {
            response = MudResponse(session: updatedSession, message: "Error logging in user: \(error)")
        }
        
        var result = [response]
        result.append(contentsOf: notifications)
        return result
    }
}
