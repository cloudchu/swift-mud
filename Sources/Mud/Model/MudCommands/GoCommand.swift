//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct GoCommand: MudCommand {
    static var token = "go"
    static var expectedArugmentCount: Int = 1
    static var requiresLogin: Bool = true
    
    let session: Session
    let direction: Direction
    
    static func create(_ arguments: [String], session: Session) -> GoCommand? {
        guard arguments.count >= expectedArugmentCount else {
            return nil
        }
        
        guard let direction = Direction(stringValue: arguments[0]) else {
            return nil
        }
        
        return GoCommand(session: session, direction: direction)
    }
    
    func execute() async -> [MudResponse] {
        guard var player = await User.find(session.playerID) else {
            return [MudResponse(session: session, message: couldNotFindPlayerMessage)]
        }
        
        guard let currentRoom = await Room.find(player.currentRoomID) else {
            return [MudResponse(session: session, message: "Could not find room: \(String(describing: player.currentRoomID))")]
        }
        
        guard let exit = currentRoom.exits.first(where: {$0.direction == direction}) else {
            return [MudResponse(session: session, message: "No exit found in direction \(direction)")]
        }
        
        guard let targetRoom = await Room.find(exit.targetRoomID) else {
            return [MudResponse(session: session, message: "Cound not find target room: \(String(describing: player.currentRoomID))")]
        }
        
        guard await exit.isPassable() else {
            return [MudResponse(session: session, message: "The exit is impassable.")]
        }
        
        var response = [MudResponse]()
        
        response.append(MudResponse(session: session, message: "You moved into a new room: \n \(targetRoom.formattedDescription)"))
        
        let exitMessages = await sendMessageToOtherPlayersInRoom(message: "\(player.username) has left the room.", player: player)
        response.append(contentsOf: exitMessages)
        
        player.currentRoomID = exit.targetRoomID
        await player.save()
        
        let enterMessages = await sendMessageToOtherPlayersInRoom(message: "\(player.username) enter the room", player: player)
        
        
        response.append(contentsOf: enterMessages)
        
        return response
    }
}
