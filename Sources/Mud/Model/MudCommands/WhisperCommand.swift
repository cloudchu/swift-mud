//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct WhisperCommand: MudCommand {
    static let token = "whisper"
    static let expectedArugmentCount: Int = 2
    static let requiresLogin: Bool = true
    
    let session: Session
    let targetPlayerName: String
    let message: String
    
    static func create(_ arguments: [String], session: Session) -> WhisperCommand? {
        guard arguments.count >= expectedArugmentCount else {
            return nil
        }
        
        let message = arguments[1..<arguments.count].joined(separator: " ")
        return WhisperCommand(session: session, targetPlayerName: arguments[0], message:message)
    }
    
    func execute() async -> [MudResponse] {
        guard let player = await User.find(session.playerID) else {
            return [MudResponse(session: session, message: couldNotFindPlayerMessage)]
        }
        
        guard let targetPlayer = await User.filter(where: {$0.username.uppercased() == targetPlayerName.uppercased()}).first else {
            return [MudResponse(session: session, message: "There is no player \(targetPlayerName) in the game.")]
        }
        
        guard player.currentRoomID == targetPlayer.currentRoomID else {
            return [MudResponse(session: session, message: "You can only whisper to other players in the room.")]
        }
        
        guard let targetPlayerSession = SessionStorage.first(where: {$0.playerID == targetPlayer.id}) else {
            return [MudResponse(session: session, message: "You can only whisper to players that are logged in.")]
        }
        
        var result = [MudResponse(session: session, message: "You whisper to \(targetPlayerName): \(message)")]
        result.append(MudResponse(session: targetPlayerSession, message: "\(player.username) whisper to you: \(message)"))
        
        let playersInRoom = await User.filter(where: {$0.currentRoomID == player.currentRoomID})
        playersInRoom.forEach({ otherPlayer in
            if otherPlayer.id != player.id && otherPlayer.id != targetPlayer.id {
                if let otherSession = SessionStorage.first(where: {$0.playerID == otherPlayer.id}) {
                    result.append(MudResponse(session: otherSession, message: "\(player.username) whispers something to \(targetPlayerName), but you can't quite make out what is said."))
                }
            }
            
        })
        
        return result
    }
}
