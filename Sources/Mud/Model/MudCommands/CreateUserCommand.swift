//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct CreateUserCommand: MudCommand {
    static let token = "create_user"
    static let expectedArugmentCount = 2
    static let requiresLogin = false
    
    let session: Session
    let username: String
    let password: String
    
    static func create(_ arguments: [String], session: Session) -> CreateUserCommand? {
        guard arguments.count >= expectedArugmentCount else {
            return nil
        }
        return CreateUserCommand(session: session, username: arguments[0], password: arguments[1])
    }
    
    func execute() async -> [MudResponse] {
        var updatedSession = session
        let response: MudResponse
        
        do {
            let newUser = try await User.create(username: username, password: password, currentRoomID: Room.STARTER_ROOM_ID)
            updatedSession.playerID = newUser.id
            response = MudResponse(session: updatedSession, message: "Welcome, \(newUser.username)!")
        } catch {
            response = MudResponse(session: updatedSession, message: "Error create user: \(error)")
        }
        
        return [response]
    }
}
