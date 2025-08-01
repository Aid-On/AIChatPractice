//
//  Struct.swift
//  AIChatPractice
//
//  Created by 香村彩奈 on 2025/07/22.
//

import Foundation

struct Message {
    enum Role {
        case user
        case assistant
    }

    let role: Role
    var content: String
}


struct SimpleMessage {
    var content: String
}
