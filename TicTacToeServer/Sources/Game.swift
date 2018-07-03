//
//  Game.swift
//  TicTacToeServer
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//

import Foundation
import PerfectWebSockets
import TicTacToeShared

enum GameError: Error {
    case failedToSerializeMessageToJsonString(message: Message)
}

class Game {
    static let shared = Game()
    
    private var playerSocketInfo: [Player: WebSocket] = [:]
    private var activePlayer: Player?
    private var board = [Tile](repeating: Tile.none, count: 9)
    
    private var players: [Player] {
        return Array(self.playerSocketInfo.keys)
    }
    
    private init() {}
    
    func playerForSocket(_ aSocket: WebSocket) -> Player? {
        var aPlayer: Player? = nil
        
        self.playerSocketInfo.forEach { (player, socket) in
            if aSocket == socket {
                aPlayer = player
            }
        }
        
        return aPlayer
    }
    
    func handlePlayerLeft(player: Player) throws {
        if self.playerSocketInfo[player] != nil {
            self.playerSocketInfo.removeValue(forKey: player)
            
            let message = Message.stop()
            try notifyPlayers(message: message)
        }
    }
    
    func handleJoin(player: Player, socket: WebSocket) throws {
        if self.playerSocketInfo.count > 2 {
            return
        }
        
        self.playerSocketInfo[player] = socket
        
        if self.playerSocketInfo.count == 2 {
            try startGame()
        }
    }
    
    func handleTurn(_ board: [Tile]) throws {
        self.board = board
        
        if didPlayerWin() {
            let message = Message.finish(board: self.board, winningPlayer: self.activePlayer!)
            try notifyPlayers(message: message)
        } else if board.filter({ $0 == Tile.none }).count == 0 {
            let message = Message.finish(board: board, winningPlayer: nil)
            try notifyPlayers(message: message)
        } else {
            self.activePlayer = nextActivePlayer()!
            let message = Message.turn(board: self.board, player: self.activePlayer!)
            try notifyPlayers(message: message)
        }
    }
    
    // MARK: - Private
    
    private func setupBoard() {
        (0 ..< 9).forEach { (i) in
            board[i] = Tile.none
        }
    }
    
    private func didPlayerWin() -> Bool {
        let winningTiles: [[Int]] = [
            [0, 1, 2], // the bottm row
            [3, 4, 5], // the middle row
            [6, 7, 8], // the top row
            [0, 3, 6], // the left column
            [1, 4, 7], // the middle column
            [2, 5, 8], // the right column
            [0, 4, 8], // diagonally bottom-left to top-right
            [6, 4, 2], // diagonally top-left to bottom-right
        ]
        
        for tileIdxs in winningTiles {
            let tileIdx0 = tileIdxs[0]
            let tileIdx1 = tileIdxs[1]
            let tileIdx2 = tileIdxs[2]
            
            // Check if the 3 tiles are set and are all equal
            if (self.board[tileIdx0] != Tile.none &&
                self.board[tileIdx0] == self.board[tileIdx1] &&
                self.board[tileIdx1] == self.board[tileIdx2]) {
                return true
            }
        }
        
        return false
    }
    
    private func startGame() throws {
        setupBoard()
        
        self.activePlayer = randomPlayer()
        let message = Message.turn(board: self.board, player: self.activePlayer!)
        try notifyPlayers(message: message)
    }
    
    private func randomPlayer() -> Player {
        let randomIdx = Int(arc4random() % UInt32(self.players.count))
        return players[randomIdx]
    }
    
    private func nextActivePlayer() -> Player? {
        return self.players.filter({ $0 != self.activePlayer }).first
    }
    
    private func notifyPlayers(message: Message) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        self.playerSocketInfo.values.forEach({
            $0.sendStringMessage(string: jsonString, final: true, completion: {
                print("did send message: \(message.type)")
            })
        })
    }
}
