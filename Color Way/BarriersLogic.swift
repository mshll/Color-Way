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

extension GameScene {




    func summonBarriers(){

        // BARRIERS.
//        var B1 = SKShapeNode()
//        var B2 = SKShapeNode()
//        var B3 = SKShapeNode()
//        var B4 = SKShapeNode()
//        var B5 = SKShapeNode()
        var barr = Array(repeating: SKShapeNode(), count: 5)



        colorsArray.shuffle()

        barriersLine = SKNode()

        let barrierSize = CGSize(width: displaySize.width / 5, height: 25)
        let barrier = SKShapeNode(rectOf: barrierSize, cornerRadius: 10)
        barrier.position = CGPoint(x: 0, y: 0)
        barrier.strokeColor = .clear

        //barrier.fillTexture = gradientTexture

        barrier.physicsBody = SKPhysicsBody(rectangleOf: barrier.frame.size)
        barrier.physicsBody?.categoryBitMask = phyCatg.lineCATG
        barrier.physicsBody?.collisionBitMask = 0
        barrier.physicsBody?.contactTestBitMask = phyCatg.playerCATG
        barrier.physicsBody?.affectedByGravity = false
        barrier.physicsBody?.isDynamic = false

        
        let barrXPosition = [-(barrier.frame.width * 2), -barrier.frame.width, displaySize.minX, barrier.frame.width, barrier.frame.width * 2]
        
        for i in 0...4 {
            barr[i] = barrier.copy() as! SKShapeNode
            barr[i].fillColor = colorsArray[i]
            barr[i].position.x = barrXPosition[i]
            
            barr[i].setScale(0.9)
            barr[i].physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
            
            barr[i].name = "B\(i+1)-\(barrierNum)"
            barriersLine.addChild(barr[i])
        }

        
        barriersLine.position.y = (displaySize.height / 2) + barriersLine.frame.height
        barriersLine.name = "BLine"
        barriersLine.run(moveRemoveAction, withKey: "moveRemove")
        addChild(barriersLine)
        barrierNum += 1
    }



    func summonCoins(){
        var lootArray = Array(repeating: SKSpriteNode(), count: 5)
        
        let coinRotate = SKAction.repeatForever(.rotate(byAngle: .pi, duration: 0.5))
        var spawnedShield = false

        
        func randomizeLoot(node: SKSpriteNode){
            let rand = randomNumber(inRange: 1...1000)

            if rand <= lootsPercentage[0]{
                node.texture = SKTexture(imageNamed: loots[0])
                node.name = loots[0]
                node.isHidden = true

            } else if rand <= (lootsPercentage[0] + lootsPercentage[1]){
                node.texture = SKTexture(imageNamed: loots[1])
                node.run(coinRotate)
                node.name = loots[1]

            } else if rand <= (lootsPercentage[0] + lootsPercentage[1] + lootsPercentage[2]) && spawnedShield == false{
                node.texture = SKTexture(imageNamed: loots[2])
                node.name = loots[2]
                node.addGlow()
                spawnedShield = true

            } else {
                node.texture = SKTexture(imageNamed: loots[0])
                node.name = loots[3]
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
            
            randomizeLoot(node: lootArray[i])
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
            self.summonCoins()

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
