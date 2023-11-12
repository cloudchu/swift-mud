//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct SayCommand: MudCommand {
    static let token = "say"
    static let expectedArugmentCount: Int = 1
    static let requiresLogin: Bool = true
    
    let session: Session
    let sentence: String
    
    static func create(_ arguments: [String], session: Session) -> SayCommand? {
        guard arguments.count >= expectedArugmentCount else {
            return nil
        }
        
        return SayCommand(session: session, sentence: arguments.joined(separator: " "))
    }
    
    func execute() async -> [MudResponse] {
        guard let player = await User.find(session.playerID) else {
            return [MudResponse(session: session, message: couldNotFindPlayerMessage)]
        }
        
        var result = [MudResponse(session: session, message: "You say: \(sentence)")]
        result.append(contentsOf: await sendMessageToOtherPlayersInRoom(message: "\(player.username) says: \(sentence)", player: player))
        
        return result
    }
}
