//
//  barriersLogic.swift
//  Color Way
//
//  Created by Meshal Almutairi on 5/6/20.
//  Copyright © 2020 Meshal Almutairi. All rights reserved.
//

import Foundation
import Spring
import SpriteKit
import SwiftyUserDefaults
import UIKit

extension GameScene {
    func getRandomWeightedLoot() -> Int {
        var i = 0, randNum = randomNumber(inRange: 1...100)
        for weight in lootWeight {
            if randNum < weight {
                return i
            }
            randNum -= weight
            i += 1
        }
        print("ERROR: couldn't select element")
        return 0
    }

    func summonBarriers() {
        if gameState != INGAME { return }
        
        let firstObst = 9 // First obstacle - when barriers start with the same color then change to their true color after a delay
        randomColor = colorsArray.randomItem() // Update random color

        // All 5 barriers array.
        var barr = Array(repeating: SKShapeNode(), count: 5)
        
        // Randomize colors
        colorsArray.shuffle()

        // Line for barriers
        barriersLine = SKNode()
        let barrierSize = CGSize(width: displaySize.width/5, height: 25)
        
        // Barrier template
        let barrier = SKShapeNode(rectOf: barrierSize, cornerRadius: 10)
        barrier.position = CGPoint(x: 0, y: 0)
        barrier.strokeColor = .clear
        barrier.physicsBody = SKPhysicsBody(rectangleOf: barrier.frame.size)
        barrier.physicsBody?.categoryBitMask = phyCatg.lineCATG
        barrier.physicsBody?.collisionBitMask = 0
        barrier.physicsBody?.contactTestBitMask = phyCatg.playerCATG
        barrier.physicsBody?.affectedByGravity = false
        barrier.physicsBody?.isDynamic = false
        
        // Initiate all 5 barriers
        for i in 0...4 {
            barr[i] = barrier.copy() as! SKShapeNode
            barr[i].position.x = screenSection[i]
            
            if barrierNum >= firstObst { // Check if reached first obstacle
                barr[i].fillColor = randomColor // Vague color for all barriers
            } else {
                barr[i].fillColor = colorsArray[i] // True colors
            }
            
            barr[i].setScale(0.9)
            barr[i].physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
            
            barr[i].name = "B\(i + 1)-\(barrierNum)"
            barriersLine.addChild(barr[i])
        }
        
        // Keeps barriers color vague for a bit
        if barrierNum >= firstObst {
            let clrsArray = colorsArray
            self.run(.wait(forDuration: vagueClrDur)) {
                [self] in
                for i in 0...4 {
                    barr[i].run(.colorTransitionAction(fromColor: randomColor /* vagueClr */, toColor: clrsArray[i], duration: 0.3)) {
                        barr[i].fillColor = clrsArray[i]
                    }
                }
            }
        }
        
        // Show new highscore line
        if barrierNum == Defaults[\.highScore] && Defaults[\.highScore] > 0 {
            let lblNewHi = SKLabelNode()
            lblNewHi.text = "--------------------------------------------------------------------------- NEW HIGHSCORE ---------------------------------------------------------------------------"
            lblNewHi.fontName = "Odin-Bold"
            lblNewHi.fontSize = 24
            lblNewHi.color = clrWhite
            lblNewHi.position.x = displaySize.minX
            lblNewHi.position.y = barrier.position.y + (lblNewHi.frame.height * 2.5)
            lblNewHi.alpha = 0.2
            lblNewHi.verticalAlignmentMode = .center
            lblNewHi.horizontalAlignmentMode = .center
            barriersLine.addChild(lblNewHi)
            lblNewHi.run(.repeatForever(.sequence([.colorize(with: colorsArray[0], colorBlendFactor: 1, duration: 0.3),
                                                   .colorize(with: colorsArray[1], colorBlendFactor: 1, duration: 0.3),
                                                   .colorize(with: colorsArray[2], colorBlendFactor: 1, duration: 0.3),
                                                   .colorize(with: colorsArray[3], colorBlendFactor: 1, duration: 0.3),
                                                   .colorize(with: colorsArray[4], colorBlendFactor: 1, duration: 0.3)])))
        }

        // Place the barriers line and start moving it
        barriersLine.position.y = frame.maxY + barriersLine.frame.height
        barriersLine.name = "barrierLine"
        barriersLine.run(moveRemoveAction, withKey: "barrierMoveRemove")
        addChild(barriersLine)
        barrierNum += 1
    }

    func summonLoot() {
        if gameState != INGAME { return }
        
        var lootArray = Array(repeating: SKSpriteNode(), count: 5)
        var lootCount = Array(repeating: 0, count: 5) // Cmp against [5, 3, 2, 2, 0]

        func getLootFor(node: SKSpriteNode) {
            // Get random loot from weighted loot array
            let loot = self.getRandomWeightedLoot()
            
            // For pulse animation
            let pulseUp = SKAction.scale(to: 0.135, duration: 0.1) // og scale 0.12
            let pulseDown = SKAction.scale(to: 0.11, duration: 0.1)
            let pulse = SKAction.sequence([pulseUp, pulseDown, pulseUp, pulseDown, .wait(forDuration: 0.3)])
            let repeatPulse = SKAction.repeatForever(pulse)
            
            // Coin flip animation
            let flipDur = 0.4
            let flipScale = SKAction.sequence([.scaleX(to: 0.012, duration: flipDur),
                                               .scaleX(to: 0.12, duration: flipDur)])
            let flipDarken = SKAction.sequence([.colorize(with: SKColor.black, colorBlendFactor: 0.25, duration: flipDur),
                                                .colorize(withColorBlendFactor: 0, duration: flipDur)])
            let flip = SKAction.group([flipScale, flipDarken])
            let repeatFlip = SKAction.repeatForever(flip)

            // Rotate animation
            let repeatRotate = SKAction.repeatForever(.rotate(byAngle: .pi, duration: 5))
            
            node.texture = SKTexture(imageNamed: loots[loot])
            node.name = loots[loot]

            switch loot {
            case 1 where lootCount[loot] < lootMax[loot]:
                node.run(repeatFlip)
                
            case 2 where lootCount[loot] < lootMax[loot]:
                let glowNode = SKSpriteNode(texture: SKTexture(imageNamed: "\(loots[loot])Glow"))
                glowNode.zPosition = -1
                glowNode.setScale(1.1)
                node.addChild(glowNode)
                node.run(repeatPulse)
                
            case 3 where lootCount[loot] < lootMax[loot]:
                let glowNode = SKSpriteNode(texture: SKTexture(imageNamed: "\(loots[loot])Glow"))
                glowNode.zPosition = -1
                glowNode.setScale(1.1)
                node.addChild(glowNode)
//                node.run(repeatRotate)
                
            // case 4 where lootCount[loot] < lootMax[loot]:
            default:
                node.isHidden = true
                node.name = loots[0]
            }
            
            lootCount[loot] += 1
        }
        
        lootLine = SKNode()
        lootLine.position.y = frame.maxY + lootLine.frame.height
        lootLine.name = "lootLine"
        
        let lootNode = SKSpriteNode(texture: SKTexture(imageNamed: "coin"))
        lootNode.physicsBody = SKPhysicsBody(rectangleOf: lootNode.frame.size)
        lootNode.physicsBody?.categoryBitMask = phyCatg.coinCATG
        lootNode.physicsBody?.collisionBitMask = 0
        lootNode.physicsBody?.contactTestBitMask = phyCatg.playerCATG
        lootNode.physicsBody?.affectedByGravity = false
        lootNode.physicsBody?.isDynamic = false
        
        for i in 0...4 {
            lootArray[i] = lootNode.copy() as! SKSpriteNode
            lootArray[i].physicsBody = (lootNode.physicsBody?.copy() as! SKPhysicsBody)
            
            lootArray[i].setScale(0.12)
            
            getLootFor(node: lootArray[i])
            lootArray[i].position.x = screenSection[i]
            lootLine.addChild(lootArray[i])
        }

        lootLine.run(moveRemoveAction, withKey: "lootMoveRemove")
        addChild(lootLine)
    }

    func startSpawning() {
        func setMoveRemoveActions() {
            // Set the move-remove action [for both barriers and loot]
            distanceBarr = CGFloat(displaySize.height + (barriersLine.frame.height * 3))
            moveLine = SKAction.moveBy(x: 0, y: -distanceBarr, duration: TimeInterval((spawnDur/450) * distanceBarr))
            moveRemoveAction = .sequence([moveLine, .removeFromParent()])
            vagueClrDur = ((spawnDur/2000) * distanceBarr)
        }
        
        setMoveRemoveActions()
        let spawnDelay: CGFloat = 1.75
        
        let spawningAction = SKAction.sequence([.run {
            [self] in
            
            // Speed up barriers movement after reaching a score of 5
            if barrierNum >= 4, spawnDur > 1.5 {
                spawnDur -= 0.1
                setMoveRemoveActions()
            }
            
            summonBarriers()
            run(.wait(forDuration: spawnDelay/2)) {
                self.summonLoot()
            }
            
        }, .wait(forDuration: spawnDelay)])
        
        self.run(.repeatForever(spawningAction), withKey: "spawning")
    }
}
