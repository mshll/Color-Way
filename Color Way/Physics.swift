//
//  Physics.swift
//  Color Way
//
//  Created by Meshal on 4/17/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

import Spring
import AnimatedCollectionViewLayout
import SwiftyUserDefaults
import SKTextureGradient


struct phyCatg {
    static let playerCATG : UInt32 = 0x1 << 1
    static let lineCATG : UInt32 = 0x1 << 2
    static let coinCATG : UInt32 = 0x1 << 3
}



extension GameScene {
    //: SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let first = contact.bodyA
        let second = contact.bodyB

        // Player contact with barriers
        if (first.categoryBitMask == phyCatg.playerCATG && second.categoryBitMask == phyCatg.lineCATG) {

            if canCheck {
                checkObj(second.node as? SKShapeNode)
           }
        }

        
        // Player contact with loot
        if (first.categoryBitMask == phyCatg.playerCATG && second.categoryBitMask == phyCatg.coinCATG){

            switch second.node!.name{
            case loots[0]:
                print("empty")

            case loots[1]:
                let secondNode = second.node!.copy() as! SKSpriteNode
                secondNode.removeAllActions()
                second.node!.alpha = 0
                secondNode.run(.sequence([.scale(by: 2, duration: 0.05),
                                          .scale(to: 0, duration: 0.2)]))
                secondNode.run(.move(to: convertPoint(fromView: coinsLabel.center), duration: 0.2)) {
                    secondNode.removeFromParent()
                    self.coinsLabel.animation = "pop"
                    self.coinsLabel.animate()
                }
                addChild(secondNode)
                Defaults[\.coinsOwned] += 1
                coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")


            case loots[2]:
                // Remove existing shield (if applicable)
                player.childNode(withName: "shieldParticle")?.removeFromParent()
                // Add shield again
                second.node?.run(.fadeOut(withDuration: 0.3))
                let shieldNode = SKSpriteNode(imageNamed: "shieldParticle")
                shieldNode.name = "shieldParticle"
                shieldNode.setScale(1.5)
                shieldNode.position.y = player.frame.midY
                player.addChild(shieldNode)
                haveShield = true
                shieldNode.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.5)))
                delayCode(10){
                    shieldNode.run(.fadeOut(withDuration: 0.2), completion: {
                        if (self.player.childNode(withName: "shieldParticle") != nil){
                            shieldNode.removeFromParent()
                            self.haveShield = false
                        }
                    })
                }

            default:
                print("nil")
                
            } // end of switch

        } // End of player contact w coins/powerups
        
    }
    
    func checkObj(_ obj : SKShapeNode?){
        
        func destroyBarrier() {
            let expo = SKEmitterNode(fileNamed: "explosionParticle.sks")!
            expo.particleColorSequence = nil
            expo.particleColor = (obj?.fillColor)!
            expo.position = (obj?.position)!
            expo.targetNode = self
            childNode(withName: "BLine")?.addChild(expo)
            obj?.isHidden = true
            
        }
        
        canCheck = false
        
        if obj?.fillColor == player.color {
            print("Player color matches barrier.")
            
            AddingScore()
            
            // Destroying barrier
            destroyBarrier()
            
            // Change Player color
            playerParticle.particleColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))]
            player.changeColorTo(playerParticle.particleColor, dur: 0.3)

            self.run(.wait(forDuration: 0.5)) {
                self.canCheck = true
            }

            
            
        } else {
            print("Wrong contact")
            
            if haveShield == true{
                
                // Destroy barrier
                destroyBarrier()
                
                // Change Player color
                playerParticle.particleColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))]
                player.changeColorTo(playerParticle.particleColor, dur: 0.3)

                
                // Remove shield:
                player.childNode(withName: "shieldParticle")?.run(.fadeOut(withDuration: 0.2), completion: {
                    self.player.childNode(withName: "shieldParticle")?.removeFromParent()
                    self.haveShield = false
                })
                
                self.run(.wait(forDuration: 0.5)) {
                    self.canCheck = true
                }

                
            } else {
                
                // Stop barriers & loot movement
                enumerateChildNodes(withName: "BLine") { (node, error) in
                    node.speed = 0
                    self.removeAction(forKey: "Spawning")
                }
                enumerateChildNodes(withName: "CoinLine") { (node, error) in
                    node.speed = 0
                    self.removeAction(forKey: "lootSpawning")
                }
                
                
                let playerexplo = SKEmitterNode(fileNamed: "playerExplo.sks")!
                playerexplo.targetNode = self
                playerexplo.particleColorSequence = nil
                playerexplo.zPosition = player.zPosition
                playerexplo.particleColor = playerParticle.particleColor
                player.run(.fadeOut(withDuration: 0.1))
                player.addChild(playerexplo)
                playerParticle.removeFromParent()
                
                
                whenDead()
            }
            
        }
    }
    
    
}
