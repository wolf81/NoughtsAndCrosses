//
//  GameScene.swift
//  TicTacToe
//
//  Created by Wolfgang Schreurs on 03/07/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

import SpriteKit
import GameplayKit
import TicTacToeShared

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var gameBoard: SKSpriteNode!
    private var statusLabel: SKLabelNode!
    
    lazy var tileSize: CGSize = {
        let tileWidth = self.gameBoard.size.width / 3
        let tileHeight = self.gameBoard.size.height / 3
        return CGSize(width: tileWidth, height: tileHeight)
    }()
    
    override func sceneDidLoad() {
        Game.sharedInstace.start()
    }
    
    override func didMove(to view: SKView) {
        self.gameBoard = self.childNode(withName: "GameBoard") as! SKSpriteNode
        self.statusLabel = self.childNode(withName: "StatusLabel") as! SKLabelNode
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // When a user interacts with the game, make sure the player can play.
        // Upon any connection issues or when the other player has left, just reset the game
        switch Game.sharedInstace.state {
        case .active:
            if let tilePosition = tilePositionOnGameBoardForPoint(pos) {
                Game.sharedInstace.playTileAtPosition(tilePosition)
            }
        case .connected, .waiting: break
        default: Game.sharedInstace.start()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.statusLabel.text = Game.sharedInstace.state.message
        
        drawTiles(Game.sharedInstace.board)
    }
    
    func tilePositionOnGameBoardForPoint(_ point: CGPoint) -> CGPoint? {
        if self.gameBoard.frame.contains(point) == false {
            return nil
        }
        
        let positionOnBoard = self.convert(point, to: self.gameBoard)
        
        let xPos = Int(positionOnBoard.x / self.tileSize.width)
        let yPos = Int(positionOnBoard.y / self.tileSize.height)
        
        return CGPoint(x: xPos, y: yPos)
    }
    
    func drawTiles(_ tiles: [Tile]) {
        self.gameBoard.removeAllChildren()
        
        for tileIdx in 0 ..< tiles.count {
            let tile = tiles[tileIdx]
            
            if tile == .none {
                continue
            }
            
            let row = tileIdx / 3
            let col = tileIdx % 3
            
            let x = CGFloat(col) * self.tileSize.width + self.tileSize.width / 2
            let y = CGFloat(row) * self.tileSize.height + self.tileSize.height / 2
            
            if tile == .x {
                let sprite = SKSpriteNode(imageNamed: "Player_X")
                sprite.position = CGPoint(x: x, y: y)
                self.gameBoard.addChild(sprite)
            } else if tile == .o {
                let sprite = SKSpriteNode(imageNamed: "Player_O")
                sprite.position = CGPoint(x: x, y: y)
                self.gameBoard.addChild(sprite)
            }
        }
    }
}
