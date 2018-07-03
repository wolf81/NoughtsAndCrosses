//
//  Game.swift
//  TicTacToe
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation
import TicTacToeShared
import CoreGraphics

class Game {
    static let sharedInstace = Game()
    
    // We use an array of tiles to represent the game board.
    private(set) var board = [Tile]()
    
    // We use this client for interacting with the server.
    private (set) var client = TicTacToeClient()
    
    // The state is initally disconnected - wait for the client to connect.
    private(set) var state: GameState = .disconnected
    
    // This player instance represents the player behind this device.
    private (set) var player = Player()
    
    // The tile type for the currently active player
    private (set) var playerTile: Tile = .none
    
    // MARK: - Public
    
    func start() {
        self.client.delegate = self
        self.client.connect()
    }
    
    func stop() {
        self.client.disconnect()
    }
    
    func playTileAtPosition(_ position: CGPoint) {
        let tilePosition = Int(position.y * 3 + position.x)
        
        let tile = self.board[tilePosition]
        if tile == .none {
            self.board[tilePosition] = self.playerTile
            self.client.playTurn(updatedBoard: self.board, activePlayer: self.player)
            self.state = .waiting
        }
    }
    
    // MARK: - Private
    
    private init() { /* singleton */ }
    
    private func configurePlayerTileIfNeeded(_ playerTile: Tile) {
        let emptyTiles = board.filter({ $0 == .none })
        if emptyTiles.count == 9 {
            self.playerTile = playerTile
        }
    }
}

// MARK: - TicTacToeClientDelegate

extension Game: TicTacToeClientDelegate {
    func clientDidDisconnect(error: Error?) {
        self.state = .disconnected
    }
    
    func clientDidConnect() {
        self.client.join(player: self.player)
        self.state = .connected
    }
    
    func clientDidReceiveMessage(_ message: Message) {
        if let board = message.board {
            self.board = board
        }
        
        switch message.type {
        case .finish:
            self.playerTile = .none
            
            if let winningPlayer = message.player {
                self.state = (winningPlayer == self.player) ? .playerWon : .playerLost
            } else {
                self.state = .draw
            }
        case .stop:
            self.board = [Tile]()
            
            self.playerTile = .none
            
            self.state = .stopped
        case .turn:
            guard let activePlayer = message.player else {
                print("no player found - this should never happen")
                return
            }
            
            if activePlayer == self.player {
                self.state = .active
                configurePlayerTileIfNeeded(.x)
            } else {
                self.state = .waiting
                configurePlayerTileIfNeeded(.o)
            }
        default: break
        }
    }
}
