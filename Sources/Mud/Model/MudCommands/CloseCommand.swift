//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct CloseCommand: MudCommand {
    static let token = "close"
    static let expectedArugmentCount: Int = 0
    static let requiresLogin: Bool = false
    
    let session: Session
    
    static func create(_ arguments: [String], session: Session) -> CloseCommand? {
        return CloseCommand(session: session)
    }
    
    func execute() async -> [MudResponse] {
        var updatedSession = session
        updatedSession.shouldClose = true
        return [MudResponse(session: updatedSession, message: "Good Bye!")]
    }
}
