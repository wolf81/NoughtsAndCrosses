//
//  GameState.swift
//  TicTacToe
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

enum GameState {
    case active // the player can play his turn
    case waiting // waiting for the other player's turn
    case connected // connected with the back-end
    case disconnected // disconnected from the back-end
    case stopped // game stopped, perhaps because the other player left the game
    case playerWon // the player won
    case playerLost // the player lost
    case draw // the game ended in a draw
    
    var message: String {
        switch self {
        case .active: return "Your turn to play ..."
        case .connected: return "Waiting for player to join"
        case .disconnected: return "Disconnected"
        case .playerWon: return "You won :)"
        case .playerLost: return "You lost :("
        case .draw: return "It's a draw :|"
        case .waiting: return "Waiting for other player ..."
        case .stopped: return "Player left the game"
        }
    }
}
