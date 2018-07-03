//
//  GameHandler.swift
//  TicTacToeServer
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//

import Foundation
import PerfectWebSockets
import PerfectHTTP
import TicTacToeShared

class GameHandler: WebSocketSessionHandler {
    // The name of the super-protocol we implement.
    // This is optional, but it should match whatever the client-side WebSocket is initialized with.
    let socketProtocol: String? = "tictactoe"
    
    // This function is called by the WebSocketHandler once the connection has been established.
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        // This callback is provided:
        //  the received data
        //  the message's op-code
        //  a boolean indicating if the message is complete
        // (as opposed to fragmented)
        socket.readStringMessage { (string, op, fin) in
            // The data parameter might be nil here if either a timeout
            // or a network error, such as the client disconnecting, occurred.
            // By default there is no timeout.
            guard let string = string else {
                // This block will be executed if, for example, the game was closed.
                if let player = Game.shared.playerForSocket(socket) {
                    print("socket closed for \(player.id)")
                    
                    do {
                        try Game.shared.handlePlayerLeft(player: player)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                
                return socket.close()
            }
            
            do {
                let decoder = JSONDecoder()
                guard let data = string.data(using: .utf8) else {
                    return print("failed to covert string into data object: \(string)")
                }
                
                let message: Message = try decoder.decode(Message.self, from: data)
                switch message.type {
                case .join:
                    guard let player = message.player else {
                        return print("missing player in join message")
                    }
                    
                    try Game.shared.handleJoin(player: player, socket: socket)
                case .turn:
                    guard let board = message.board else {
                        return print("board not provided")
                    }
                    
                    try Game.shared.handleTurn(board)
                default:
                    break
                }
            } catch {
                print("Failed to decode JSON from Received Socket Message")
            }
            
            // Done working on this message? Loop back around and read the next message.
            self.handleSession(request: request, socket: socket)
        }
    }
}
