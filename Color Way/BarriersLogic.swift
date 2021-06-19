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
import ChameleonFramework

extension GameScene {




    func summonBarriers(){

        // BARRIERS.
        var B1 = SKShapeNode()
        var B2 = SKShapeNode()
        var B3 = SKShapeNode()
        var B4 = SKShapeNode()
        var B5 = SKShapeNode()



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

        B3 = barrier.copy() as! SKShapeNode
        B3.fillColor = colorsArray[0]
        B3.position.x = displaySize.minX

        B4 = barrier.copy() as! SKShapeNode
        B4.fillColor = colorsArray[1]
        B4.position.x = B3.frame.width

        B5 = barrier.copy() as! SKShapeNode
        B5.fillColor = colorsArray[2]
        B5.position.x = B3.frame.width * 2

        B2 = barrier.copy() as! SKShapeNode
        B2.fillColor = colorsArray[3]
        B2.position.x = -B3.frame.width

        B1 = barrier.copy() as! SKShapeNode
        B1.fillColor = colorsArray[4]
        B1.position.x = -(B3.frame.width * 2)

        barriersLine.position.y = (displaySize.height / 2) + barriersLine.frame.height

        B1.setScale(0.9)
        B2.setScale(0.9)
        B3.setScale(0.9)
        B4.setScale(0.9)
        B5.setScale(0.9)

        B1.physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
        B2.physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
        B3.physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
        B4.physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)
        B5.physicsBody = (barrier.physicsBody?.copy() as! SKPhysicsBody)

        barriersLine.name = "BLine"

        B1.name = "B1-\(barrierNum)"
        B2.name = "B2-\(barrierNum)"
        B3.name = "B3-\(barrierNum)"
        B4.name = "B4-\(barrierNum)"
        B5.name = "B5-\(barrierNum)"


        barriersLine.addChild(B1)
        barriersLine.addChild(B2)
        barriersLine.addChild(B3)
        barriersLine.addChild(B4)
        barriersLine.addChild(B5)






        barriersLine.run(moveRemoveAction, withKey: "moveRemove")
        addChild(barriersLine)
        barrierNum += 1
    }



    func summonCoins(){

        coinLine = SKNode()

        coinLine.position.y = (displaySize.height / 2) + coinLine.frame.height

        func coinNode() -> SKSpriteNode{
            var coinNode : SKSpriteNode{
                let coinNode = SKSpriteNode(texture: SKTexture(imageNamed: "coin"))


                //coinNode.texture = SKTexture(imageNamed: "coin")
                coinNode.setScale(0.12)
                coinNode.physicsBody = SKPhysicsBody(rectangleOf: coinNode.frame.size)
                coinNode.physicsBody?.categoryBitMask = phyCatg.coinCATG
                coinNode.physicsBody?.collisionBitMask = 0
                coinNode.physicsBody?.contactTestBitMask = phyCatg.playerCATG
                coinNode.physicsBody?.affectedByGravity = false
                coinNode.physicsBody?.isDynamic = false
                return coinNode
            }
            return coinNode
        }

        coinLine.name = "CoinLine"



        let coin1 = coinNode()
        let coin2 = coinNode()
        let coin3 = coinNode()
        let coin4 = coinNode()
        let coin5 = coinNode()


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

        randomizeLoot(node: coin1)
        randomizeLoot(node: coin2)
        randomizeLoot(node: coin3)
        randomizeLoot(node: coin4)
        randomizeLoot(node: coin5)

        coin1.position.x = spot1
        coin2.position.x = spot2
        coin3.position.x = spot3
        coin4.position.x = spot4
        coin5.position.x = spot5

        coinLine.addChild(coin1)
        coinLine.addChild(coin2)
        coinLine.addChild(coin3)
        coinLine.addChild(coin4)
        coinLine.addChild(coin5)

        //coin1.addGlow(radius: 50)
        //coin2.addGlow(radius: 50)
        //coin3.addGlow(radius: 50)
        //coin4.addGlow(radius: 50)
        //coin5.addGlow(radius: 50)

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
            self.run(.repeatForever(CoinspawnDelay), withKey: "CoinSpawning")
        }
        



        let Coindistance = CGFloat(displaySize.height + (barriersLine.frame.height * 3))
        let CoinmoveLine = SKAction.moveBy(x: 0, y: -Coindistance, duration: TimeInterval((dur/450) * Coindistance))
        CoinmoveRemoveAction = .sequence([CoinmoveLine, .removeFromParent()])

    }




}
