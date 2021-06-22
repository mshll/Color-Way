//
//  barriersLogic.swift
//  Color Way
//
//  Created by Meshal Almutairi on 5/6/20.
//  Copyright © 2020 Meshal Almutairi. All rights reserved.
//


import Foundation
import UIKit
import SpriteKit
import SwiftyUserDefaults
import Spring

extension GameScene {


    func getRandomWeightedLoot(_ elements: [String], _ weights: [Int]) -> String {
        var randNum = randomNumber(inRange: 1...100)
        for (element, weight) in zip(elements, weights) {
            
            if randNum < weight {
                return element
            }
            randNum -= weight
        }
        print("ERROR: couldn't select element")
        return elements[0]
    }


    func summonBarriers(){
        let firstObst = 4
        let vagueClr = player.color

        // All 5 barriers array.
        var barr = Array(repeating: SKShapeNode(), count: 5)
        
        // Randomize colors
        colorsArray.shuffle()

        // Line for barriers
        barriersLine = SKNode()
        let barrierSize = CGSize(width: displaySize.width / 5, height: 25)
        
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

        // Position for each barrier
        let barrXPosition = [-(barrier.frame.width * 2), -barrier.frame.width, displaySize.minX, barrier.frame.width, barrier.frame.width * 2]
        
        // Initiate all 5 barriers
        for i in 0...4 {
            barr[i] = barrier.copy() as! SKShapeNode
            barr[i].position.x = barrXPosition[i]
            
            if barrierNum >= firstObst {
                barr[i].fillColor = vagueClr
            } else {
                barr[i].fillColor = colorsArray[i]
            }
            
            barr[i].setScale(0.9)
            barr[i].physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
            
            barr[i].name = "B\(i+1)-\(barrierNum)"
            barriersLine.addChild(barr[i])
            
        }
        
        
        // Keeps barriers color vague until after 1.3 seconds
        if barrierNum >= firstObst {
            colorsArray.shuffle()
            self.run(.wait(forDuration: 1.3)) {
                [self] in
                for i in 0...4 {
                    barr[i].run(.colorTransitionAction(fromColor: vagueClr, toColor: colorsArray[i], duration: 0.3)) {
                        barr[i].fillColor = colorsArray[i]
                    }
                }
                
            }
        }
        
        
        // Show new highscore line
        if barrierNum == Defaults[\.highScore] && Defaults[\.highScore] > 0 {
            let lblNewHi = SKLabelNode()
            lblNewHi.text = "---------------------------------------------------------------------------NEW HIGHSCORE---------------------------------------------------------------------------"
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
        barriersLine.position.y = (displaySize.height / 2) + barriersLine.frame.height
        barriersLine.name = "BLine"
        barriersLine.run(moveRemoveAction, withKey: "moveRemove")
        addChild(barriersLine)
        barrierNum += 1
    }



    func summonLoot(){
        var lootArray = Array(repeating: SKSpriteNode(), count: 5)
        
        let coinRotate = SKAction.repeatForever(.rotate(byAngle: .pi, duration: 0.5))
        var spawnedShield = false

        
        func getLootFor(node: SKSpriteNode){
            
            // Get random loot from weighted loot array
            let loot = getRandomWeightedLoot(loots, lootWeight)
            
            // For pulse animation
            let pulseUp = SKAction.scale(to: 0.135, duration: 0.1) // og scale 0.12
            let pulseDown = SKAction.scale(to: 0.11, duration: 0.1)
            let pulse = SKAction.sequence([pulseUp, pulseDown, pulseUp, pulseDown, .wait(forDuration: 0.3)])
            let repeatPulse = SKAction.repeatForever(pulse)
            
            
            node.texture = SKTexture(imageNamed: loot)
            node.name = loot
            
            switch loot {
            
            case loots[0]:
                node.isHidden = true
                
            case loots[1]:
                node.run(coinRotate)
                
            case loots[2]:
                if !spawnedShield {
                    node.addGlow()
                    node.run(repeatPulse)
                    spawnedShield = true
                } else {
                    node.name = loots[0]
                    node.isHidden = true
                }
                
            case loots[3]:
                node.addGlow()
                node.run(repeatPulse)
                
            default:
                print("Error assigning loot")
                node.isHidden = true
            }
            
        }
        
        
        coinLine = SKNode()
        coinLine.position.y = (displaySize.height / 2) + coinLine.frame.height
        coinLine.name = "CoinLine"
        
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
            lootArray[i].position.x = screenSpots[i]
            coinLine.addChild(lootArray[i])
            
        }

        coinLine.run(CoinmoveRemoveAction, withKey: "CoinmoveRemove")
        addChild(coinLine)
    }





    func startSpawning(){

        let dur: CGFloat = 2.0

        let spawn = SKAction.run {
            () in
            self.summonBarriers()

        }
        let delay = SKAction.wait(forDuration: TimeInterval(dur))
        let spawnDelay = SKAction.sequence([spawn,delay])
        self.run(.repeatForever(spawnDelay), withKey: "Spawning")

        let distance = CGFloat(displaySize.height + (barriersLine.frame.height * 3))
        let moveLine = SKAction.moveBy(x: 0, y: -distance, duration: TimeInterval((dur/450) * distance))
        moveRemoveAction = .sequence([moveLine, .removeFromParent()])


        //COINS SPAWNING...ETC:
        let Coinspawn = SKAction.run {
            () in
            self.summonLoot()

        }
        let Coindelay = SKAction.wait(forDuration: TimeInterval(dur))
        let CoinspawnDelay = SKAction.sequence([Coinspawn,Coindelay])


        self.run(.wait(forDuration: 1.0)) {
            self.run(.repeatForever(CoinspawnDelay), withKey: "lootSpawning")
        }
        

        let Coindistance = CGFloat(displaySize.height + (barriersLine.frame.height * 3))
        let CoinmoveLine = SKAction.moveBy(x: 0, y: -Coindistance, duration: TimeInterval((dur/450) * Coindistance))
        CoinmoveRemoveAction = .sequence([CoinmoveLine, .removeFromParent()])

    }




}
