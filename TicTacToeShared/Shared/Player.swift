//
//  Player.swift
//  TicTacToeShared
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum PlayerError: Error {
    case creationFailed
}

public class Player: Hashable, Codable {
    public let id: String
    
    public init() {
        self.id = NSUUID().uuidString
    }
    
    public init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw PlayerError.creationFailed
        }
        
        self.id = id
    }
    
    // MARK: - Hashable
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
