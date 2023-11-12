//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/29.
//

import Foundation

struct Room : DBType {
    static var storage = AwesomeDB<Room>()
    static var persist = true
    
    let id: UUID
    
    let name: String
    let description: String
    let exits: [Exit]
    
    var formattedDescription: String {
        """
        \(name)
        \(description)
        There are exits: \(exitsAsString)
        
        """
    }
    
    static let STARTER_ROOM_ID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    var exitsAsString: String {
        let direction = exits.map {$0.direction.rawValue}
        return direction.joined(separator: " ")
    }
    
//    static func find(_ id: UUID?) async -> Room? {
//        if (id == nil) {
//            return nil
//        }
//        
//        return await storage.first(where: {$0.id == id})
//    }
}

struct Exit: Codable {
    let direction: Direction
    let targetRoomID: UUID
    let doorID: UUID?
    
    func isPassable() async -> Bool {
        print("isPassable: doorID: \(String(describing: doorID))")
        guard let doorID else {
            return true
        }
        
        guard let door = await Door.find(doorID) else {
            print("Could not find door with id: \(doorID).")
            return false
        }
        
        print("isPassable: find door: \(door)")
        
        return door.isOpen
    }
}

enum Direction : String, Codable {
    case North
    case South
    case East
    case West
    case Up
    case Down
    case In
    case Out
    
    var opposite: Direction {
        switch self {
        case .North:
            return .South
        case .South:
            return .North
        case .East:
            return .West
        case .West:
            return .East
        case .Up:
            return .Down
        case .Down:
            return .Up
        case .In:
            return .Out
        case .Out:
            return .In
        }
    }
    
    public init?(stringValue: String) {
        let capitalizedStringValue = stringValue.capitalized
        self.init(rawValue: capitalizedStringValue)
    }
}
