//
//  File.swift
//  
//
//  Created by Zhu Yunzhi on 2023/11/4.
//

import Foundation

struct Door: DBType {
    static var storage: AwesomeDB<Door> = AwesomeDB()
    static var persist: Bool = true
    
    let id: UUID
    
    var isOpen = false
}
