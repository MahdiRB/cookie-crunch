//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Katherine Fang on 10/27/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var level: Level!
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        level = Level()
        scene.level = level
        scene.swipeHandler = handleMove
        
        // Present the scene
        skView.presentScene(scene)
        
        beginGame()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
        scene.addTiles()
    }
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB, completion: completion)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        level.performSwap(swap)
        
        scene.animateSwap(swap) {
            self.view.userInteractionEnabled = true
        }
    }
    
    func handleMove(swap: Swap) {
        view.userInteractionEnabled = false
        level.performSwap(swap)
        
        scene.animateSwap(swap) {
            self.view.userInteractionEnabled = true
        }
    }
}