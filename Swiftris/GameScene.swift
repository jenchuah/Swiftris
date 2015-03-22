//
//  GameScene.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 31/01/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//
//  Drawing layer and animation

import SpriteKit

let BlockSize:CGFloat = 20.0

// Slowest speed at which shape travel in milliseconds.
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x:6, y:-6)
    
    // Tick is closure (ie function) that takes no parameters and returns nothing. It is optional (?) and may be nil
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    // Last time we experienced a tick.
    var lastTick:NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background@2x")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Paused state
        if lastTick == nil {
            return
        }
        
        // Else, recover time passed since last execution of update by invoking timeIntervalSinceNow on our lastTick object.
        // Note: ! symbol is required if object is of an optional type.
        // Note: We multiple result by -1000 to get a positive millisecond value.
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        
        // If time passed has exceeded tickLengthMillis then report a tick by first updating lastTick to present and then invoking our closure.
        if timePassed > tickLengthMillis {
            lastTick = NSDate()
            // The syntax we use is conditioned on whether or not tick is present. By placing a ? after the variable name, we are asking Swift to first check if tick exists and if so, invoke it with no parameters. It is shorthand for
            /*
            if tick != nil {tick!()}
            */
            tick?()
        }
    }
    
    //
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    // This function returns the precise coordinate on the screen for where a block sprite belongs based on its row and column position. The math here looks funky but just know that each sprite will be anchored at its center, therefore we need to find its center coordinate before placing it in our shapeLayer object.
    func pointForColumn(column:Int, row:Int) ->CGPoint {
        let x:CGFloat = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y:CGFloat = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion:()->()) {
        for (idx, block) in enumerate(shape.blocks) {
            // Add a shape for the first time to the scene as a preview shape. We use a dictionary to store copies of re-usable SKTexture objects since each shape will require multiple copies of the same image.
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // Place each block's sprite in the proper location. We start it at row - 2, such that the preview piece animates smoothly into place from a higher location.
            sprite.position = pointForColumn(block.column, row: block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            // Each block will fade and move into place as it appears as part of the next piece. It will move 2 rows down and fade from complete transparency to 70% opacity. This small design choice lets the playing ignore the preview piece easily if they so choose since it will be duller than the active moving piece.
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion: ()->()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row: block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.2)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: 0.2)]), completion:nil)
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:()->()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row: block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(moveToAction, completion:nil)
        }
        runAction(SKAction.waitForDuration(0.05), completion: completion)
    }
}
