//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation

enum Verb {
    case illegal
    case empty
    
    case close
    case createUser(username: String, password: String)
    case login(username: String, password: String)
    case look
    case go(direction: Direction)
    case say(sentence: String)
    case whisper(targetUserName: String, message: String)
    
    var requiresLogin: Bool {
        switch self {
        case .close:
            return false
        case .createUser:
            return false
        case .login:
            return false
        default:
            return true
        }
    }
    
    static func expectedWordCount(verb: String) -> Int {
        switch verb.uppercased() {
        case "CREATE_USER":
            return 3
        case "LOGIN":
            return 3
        case "GO":
            return 2
        case "SAY":
            return 2
        case "WHISPER":
            return 3
        default:
            return 1
        }
    }
    
    static func createVerb(from str: String) -> Verb{
        let trimmedStr = str.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmedStr.split(separator: " ")
        
        guard parts.count >= 1 && parts[0] != "" else {
            return .empty
        }
        
        guard parts.count >= expectedWordCount(verb: String(parts[0])) else {
            return .illegal
        }
        
        switch parts[0].uppercased() {
        case "CLOSE":
            return .close
        case "CREATE_USER":
            return .createUser(username: String(parts[1]), password: String(parts[2]))
        case "LOGIN":
            return .login(username: String(parts[1]), password: String(parts[2]))
        case "LOOK":
            return .look
        case "GO":
            let direction = Direction(stringValue: String(parts[1]))
            guard let direction else {
                return .illegal
            }
            return .go(direction: direction)
        case "SAY":
            // say Hello
            // say Hello, World ! --> Hello,
            
            return .say(sentence: parts.dropFirst().joined(separator: " "))
            
        case "WHISPER":
            return .whisper(targetUserName: String(parts[1]), message: parts.dropFirst(2).joined(separator: " "))
        default:
            return .illegal
        }
    }
}
