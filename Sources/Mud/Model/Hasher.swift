//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/10/28.
//

import Foundation
import Crypto

struct Hasher {
    static func hash(_ str: String) -> String {
        guard let strData = str.data(using: .utf8) else {
            fatalError("Failed to convert passed string data.")
        }
        
        let hashData = SHA512.hash(data: strData)
        
        return hashData.description
    }
    
    static func verify(password: String, hashedPassword: String) -> Bool {
        hash(password) == hashedPassword
    }
}
