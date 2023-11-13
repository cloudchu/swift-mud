//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct LookCommand: MudCommand {
    static let token: String = "look"
    static let  expectedArgumentCount: Int = 0
    static let requiresLogin: Bool = true
    
    var session: Session
    
    static func create(_ arguments: [String], session: Session) -> LookCommand? {
        LookCommand(session: session)
    }
    
    func execute() async -> [MudResponse] {
        guard let user = await User.find(session.playerID) else {
            return [MudResponse(session: session, message: couldNotFindPlayerMessage)]
        }
        
        guard let roomID = user.currentRoomID else {
            return [MudResponse(session: session, message: "Your are in LIMBO!\n")]
        }
        
        guard let room = await Room.find(roomID) else {
            return [MudResponse(session: session, message: "Could not find room with roomID \(roomID).\n")]
        }
        
        let otherPlayersInRoom = await User.filter(where: { $0.currentRoomID == roomID}).filter({$0.id != user.id})
        
        let playerString = "Players:\n" + otherPlayersInRoom.map { $0.username }.joined(separator: ", ")
        
        return [MudResponse(session: session, message: room.formattedDescription + playerString)]
    }
    
    
}
