//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/21.
//

import Foundation



@available(macOS 10.15.0, *)
struct User: DBType {
    @available(macOS 10.15.0, *)
    static var storage: AwesomeDB<User> = AwesomeDB()
    static var persist: Bool = true
    
    let id: UUID
    let username: String
    let hashedPassword: String
    var currentRoomID: UUID?
    
    init(id: UUID? = nil, username: String, password: String, currentRoomID: UUID? = nil) {
        self.id = id ?? UUID()
        self.username = username
        self.currentRoomID = currentRoomID
        self.hashedPassword = Hasher.hash(password + username.uppercased())
        
    }
    
    @available(macOS 10.15.0, *)
    static func create(username: String, password: String, currentRoomID: UUID? = nil) async throws -> User {
//        print("[\(#function)] username: \(username)")
        guard await User.first(username: username) == nil else {
            throw UserError.usernameAlreadyTaken
        }
        
        let player = User(id: UUID(), username: username, password: password, currentRoomID: currentRoomID)
        await player.save()
        return player
    }
    
    static func login(username: String, password: String) async throws -> User {
        guard let user = await User.first(username: username) else {
            throw UserError.userNotFound
        }
        
        guard Hasher.verify(password: password + username.uppercased(), hashedPassword: user.hashedPassword) else {
            throw UserError.passwordMismatch
        }
        
        return user
    }
    
    static func first(username: String) async -> User? {
        await storage.first(where: { $0.username.uppercased() == username.uppercased() })
    }
    
//    static func find(_ id: UUID?) async -> User? {
//        if id == nil {
//            return nil
//        }
//
//        return await storage.first(where: {$0.id == id})
//    }
//    
//    func save() async {
//        await Self.storage.replaceOrAddDatabaseObject(self)
//        await Self.storage.save()
//    }
    
//    static func filter(where predicate: (User) -> Bool) async -> [User] {
//        await Self.storage.filter(where: predicate)
//    }
}

enum UserError: Error {
    case usernameAlreadyTaken
    case userNotFound
    case passwordMismatch
}
