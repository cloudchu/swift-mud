//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

import Foundation

protocol Session {
    var id: UUID { get }
//    let channel: Channel
    var playerID: UUID? { get set}
    var shouldClose: Bool { get set }
    var currentString: String { get set }
}

extension Session {
    func erasingCurrentString() -> Self {
        var updatedSession = self
        updatedSession.currentString = ""
        return updatedSession
    }
}
