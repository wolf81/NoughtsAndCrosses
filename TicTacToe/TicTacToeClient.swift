//
//  TicTacToeClient.swift
//  TicTacToe
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation
import Starscream
import TicTacToeShared

protocol TicTacToeClientDelegate: class {
    func clientDidConnect()
    func clientDidDisconnect(error: Error?)
    func clientDidReceiveMessage(_ message: Message)
}

class TicTacToeClient: WebSocketDelegate {
    weak var delegate: TicTacToeClientDelegate?
    
    private var socket: WebSocket!
    
    init() {
        let url = URL(string: "http://localhost:8181/game")!
        let request = URLRequest(url: url)
        self.socket = WebSocket(request: request, protocols: ["tictactoe"], stream: FoundationStream())
        
        self.socket.delegate = self
    }
    
    // MARK: - Public
    
    func connect() {
        self.socket.connect()
    }
    
    func join(player: Player) {
        let message = Message.join(player: player)
        writeMessageToSocket(message)
    }
    
    func playTurn(updatedBoard board: [Tile], activePlayer: Player) {
        let message = Message.turn(board: board, player: activePlayer)
        writeMessageToSocket(message)
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    // MARK: - Private
    
    private func writeMessageToSocket(_ message: Message) {
        let jsonEncoder = JSONEncoder()
        
        do {
            let jsonData = try jsonEncoder.encode(message)
            self.socket.write(data: jsonData)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.clientDidConnect()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.clientDidDisconnect(error: error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            print("failed to convert text into data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let message = try decoder.decode(Message.self, from: data)
            self.delegate?.clientDidReceiveMessage(message)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // We don't deal directly with data, only strings
    }
}
