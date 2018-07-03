//
//  Message.swift
//  TicTacToeShared
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum MessageType: String, Codable {
    case join = "join"
    case turn = "turn"
    case finish = "finish"
    case stop = "stop"
}

public class Message: Codable {
    public let type: MessageType
    public let board: [Tile]?
    public let player: Player?
    
    private init(type: MessageType, board: [Tile]?, player: Player? = nil) {
        self.type = type
        self.board = board
        self.player = player
    }
    
    public static func join(player: Player) -> Message {
        return Message(type: .join, board: nil, player: player)
    }
    
    public static func stop() -> Message {
        return Message(type: .stop, board: nil)
    }
    
    public static func turn(board: [Tile], player: Player) -> Message {
        return Message(type: .turn, board: board, player: player)
    }
    
    public static func finish(board: [Tile], winningPlayer: Player?) -> Message {
        return Message(type: .finish, board: board, player: winningPlayer)
    }
}
