//
//  GameViewController.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 31/01/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {

    // Connect drawing layer and logic layer
    var scene: GameScene!
    var swiftris: Swiftris!
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    // Every time the user's finger moves more than 90% of BlockSize points across the screen, we'll move the falling shape in the corresponding direction of the pan. We keep track of the last point on the screen at which a shape movement occured or where a pan begins.
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        
        // Recover a point which defines the translation of the gesture relative to where it began. This is just a measure of the distance that the user's finger has traveled.
        let currentPoint = sender.translationInView(self.view)
        
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                
                // Check the velocity of the gesture to get direction. Positive velocity represents a gesture moving towards the right side of the screen, negative towards the left.
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                } else {
                    swiftris.moveShapeLeft()
                }
                
                // Reset reference point
                panPointReference = currentPoint
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    // Optional delegate method found in UIGestureRecognizerDelegate which will allow each gesture recognizer to work in tandem with others. However, at times a gesture recognizer may collide with another.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    // If pan gesture occur simultaneously with a swipe down gesture, to relinquish priority, thsi code performs several optional cast conditionals. These if conditionals attempt to cast the generic UIGestureRecognizer parameters as the specific types of recognizers we expect to be notified of. If the cast succeeds, the code block is executed.
    // We let the pan gesture recognizer take precedence over the swipe gesture and the tap to do likewise over the pan. 
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
                if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                    return true
                }
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Set closeure for the tick property of GameScene. *Functions are simply named closures. We've used a function named didTick()
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Add nextShape to the game layer at the preview location. When that animation completes, we reposition the underlying Shape object at the starting row and starting column before we ask GameScene to move it from the preview location to its starting position. Once that completes, we ask Swiftris for a new shape, begin ticking and add the newly established upcoming piece to the preview area.
        /*scene.addPreviewShapeToScene(swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        }*/
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Lowers shape by one row and asks GameScene to redraw shape at new location
    func didTick() {
        swiftris.letShapeFall()
        /*swiftris.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(swiftris.fallingShape!, completion: {})*/
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!){}
            self.scene.movePreviewShape(fallingShape){
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        }
        else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
    }
    
    // Make game faster as it progresses, eventually topping off at 50 milliseconds between ticks
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        
        // If any lines are removed, we update the score label and show the newest score and then animate the blocks with explosive new animation function
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks) {
                // May form brand new lines when blocks have fallen to new location, recurse
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
