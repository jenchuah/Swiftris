//
//  GameScene.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 31/01/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//

import SpriteKit

// Slowest speed at which shape travel in milliseconds.
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    
    // Tick is closure (ie function) that takes no parameters and returns nothing. It is optional (?) and may be nil
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    // Last time we experienced a tick.
    var lastTick:NSDate?
    
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
}
