//
//  GameScene.swift
//  CookieCrunch
//
//  Created by Katherine Fang on 10/27/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var level: Level!
    
    let TileWidth: CGFloat = 32.0 // Not static, because needs to be class, but class variables not supported yet.
    let TileHeight : CGFloat = 36.0 // Not static, because needs to be class, but class variables not supported yet.
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    var moveFromColumn: Int?
    var moveFromRow: Int?
    
    var swipeHandler: ((Swap) -> ())?
    var moveHandler: ((Swap) -> ())?

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        addChild(gameLayer)
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileWidth * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
    }
    
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }

    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let tileNode = SKSpriteNode(imageNamed: "Tile")
                tileNode.position = pointForColumn(column, row: row)
                tilesLayer.addChild(tileNode)
                
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let cookie = level.cookieAtColumn(column, row: row) {
                moveFromColumn = column
                moveFromRow = row
                cookie.sprite?.position = location
                cookie.sprite?.zPosition = 100
            }
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if moveFromColumn == nil { return }
        
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)

        if success {
            if let cookie = level.cookieAtColumn(moveFromColumn!, row: moveFromRow!) {
                cookie.sprite!.position = location
            }
        }
    }
    
    func trySwapToColumn(toColumn: Int, row toRow: Int) {
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(moveFromColumn!, row: moveFromRow!) {
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if moveFromColumn == nil { return }
        
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        
        if success {
            trySwapToColumn(column, row: row)
        } else if let cookie = level.cookieAtColumn(moveFromColumn!, row: moveFromRow!) {
            animateCookieHome(cookie)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        // Since this is called after we swap the actual cookies, we can check their own locations for where they are.
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        let locA = pointForColumn(swap.cookieA.column, row: swap.cookieA.row)
        let locB = pointForColumn(swap.cookieB.column, row: swap.cookieB.row)
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(locA, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(locB, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB, completion: {
            spriteA.zPosition = 0
            spriteB.zPosition = 0
        })
    }
    
    func animateCookieHome(cookie: Cookie) {
        let sprite = cookie.sprite!
        let loc = pointForColumn(cookie.column, row: cookie.row)
        
        let Duration: NSTimeInterval = 0.3
        let move = SKAction.moveTo(loc, duration: Duration)
        move.timingMode = .EaseOut
        sprite.runAction(move)

    }
    
    override func didMoveToView(view: SKView) {
        // Called when this scene moves into the view.
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        view.addGestureRecognizer(recognizer)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            var touchLocation = sender.locationInView(sender.view) // get loc in view
            touchLocation = convertPointFromView(touchLocation) // get loc relative to gamescene
            let touchedNode = nodeAtPoint(touchLocation) // This is the SKSpriteView thing.
            touchLocation = convertPoint(touchLocation, toNode: cookiesLayer) // get loc relative to cookie layer
            
            let (success, column, row) = convertPoint(touchLocation)
            if success {
                if let cookie = level.cookieAtColumn(column, row: row) {
                    let alert = UIAlertView(title: "Clicked a cookie", message: "You clicked a \(cookie.cookieType) at \(cookie.column), \(cookie.row)", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
}