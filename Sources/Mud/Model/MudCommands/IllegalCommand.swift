//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

struct IllegalCommand: MudCommand {
    static let  token: String = "illegal"
    static let  expectedArugmentCount: Int = 0
    static let requiresLogin: Bool = false
    
    let session: Session
    let passedInCommand: String
    
    static func create(_ arguments: [String], session: Session) -> IllegalCommand? {
        IllegalCommand(session: session, passedInCommand: arguments.joined())
    }
    
    func execute() async -> [MudResponse] {
        return [MudResponse(session: session, message: "`\(passedInCommand)` is not a valid command.")]
    }
}
