//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct EmptyCommand: MudCommand {
    static let token = "empty"
    static let expectedArgumentCount = 0
    static let requiresLogin = false
    
    let session: Session
    
    static func create(_ arguments: [String], session: Session) -> EmptyCommand? {
        EmptyCommand(session: session)
    }
    
    func execute() async -> [MudResponse] {
        return [MudResponse(session: session, message: "")]
    }
}
