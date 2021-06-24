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
import SwiftyUserDefaults


struct phyCatg {
    static let playerCATG : UInt32 = 0x1 << 1
    static let lineCATG : UInt32 = 0x1 << 2
    static let coinCATG : UInt32 = 0x1 << 3
}



extension GameScene {
    //: SKPhysicsContactDelegate
    
    
    func killPlayer() {
        // Stop barriers & loot movement
        removeAction(forKey: "spawning")
        enumerateChildNodes(withName: "barrierLine") { (node, error) in
            node.speed = 0
        }
        enumerateChildNodes(withName: "lootLine") { (node, error) in
            node.speed = 0
        }
        
        let playerexplo = SKEmitterNode(fileNamed: "playerExplo.sks")!
        playerexplo.targetNode = self
        playerexplo.particleColorSequence = nil
        playerexplo.zPosition = player.node.zPosition
        playerexplo.particleColor = player.particle.particleColor
        player.node.run(.fadeOut(withDuration: 0.1))
        player.node.addChild(playerexplo)
        player.particle.removeFromParent()
        
        whenDead()
    }
    
    
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

            if canCheckLoot {
                
                canCheckLoot = false
                switch second.node!.name{
                
                // Coin
                case loots[1]:
                    let secondNode = second.node!.copy() as! SKSpriteNode
                    secondNode.removeAllActions()
                    second.node!.alpha = 0
                    secondNode.run(.sequence([.scale(by: 1.5, duration: 0.05),
                                              .scale(to: 0, duration: 0.2)]))
                    secondNode.run(.move(to: convertPoint(fromView: CGPoint(x: coinsLabel.frame.maxX, y: coinsLabel.center.y)), duration: 0.2)) {
                        secondNode.removeFromParent()
                        self.coinsLabel.animation = "pop"
                        self.coinsLabel.animate()
                    }
                    addChild(secondNode)
                    Defaults[\.coinsOwned] += 1
                    coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")


                // Shield
                case loots[2]:
                    // Remove existing shield (if applicable)
                    player.node.childNode(withName: "shieldParticle")?.removeFromParent()
                    // Add shield again
                    //second.node?.run(.fadeOut(withDuration: 0.3))
                    second.node?.run(.sequence([.scale(by: 2, duration: 0.1), .scale(to: 0, duration: 0.2)]), completion: {
                        second.node?.alpha = 0
                    })
                    let shieldNode = SKSpriteNode(imageNamed: "shieldParticle")
                    shieldNode.name = "shieldParticle"
                    shieldNode.position.y = player.node.frame.midY + 60
                    player.node.addChild(shieldNode)
                    player.shield = true
                    shieldNode.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.8)))
                    
                    // Remove shield after 15 seconds
                    self.run(.wait(forDuration: 10)) {
                        
                        shieldNode.run(.repeat(.sequence([.fadeIn(withDuration: 0.25), .fadeOut(withDuration: 0.25)]), count: 10)) {
                            shieldNode.run(.fadeOut(withDuration: 0.2), completion: {
                                if (self.player.node.childNode(withName: "shieldParticle") != nil){
                                    shieldNode.removeFromParent()
                                    self.player.shield = false
                                }
                            })
                        }
                        
                    }
                    
                  
                // Skull
                case loots[3]:
                    // Check if player has a shield or not
                    if player.shield {
                        // Remove skull
                        let expo = SKEmitterNode(fileNamed: "explosionParticle.sks")!
                        expo.particleColorSequence = nil
                        expo.particleColor = clrRed
                        expo.position = (second.node?.position)!
                        expo.targetNode = self
                        childNode(withName: "lootLine")?.addChild(expo)
                        second.node?.isHidden = true
                        
                        // Remove shield
                        player.node.childNode(withName: "shieldParticle")?.run(.fadeOut(withDuration: 0.2), completion: {
                            self.player.node.childNode(withName: "shieldParticle")?.removeFromParent()
                            self.player.shield = false
                        })
                    } else { // Else kill player
                        killPlayer()
                    }
                    
                default:
                    break
                    
                } // end of switch
                
                // Renable checking for collisions
                self.run(.wait(forDuration: 0.5)) {
                    self.canCheckLoot = true
                }
                
            } // End of if canCheckLoot

        } // End of player contact with loot
        
    }
    
    
    func checkObj(_ obj : SKShapeNode?){
        
        func destroyBarrier() {
            AddingScore() // Incrementing Score
            
            // Explosion
            let expo = SKEmitterNode(fileNamed: "explosionParticle.sks")!
            expo.particleColorSequence = nil
            expo.particleColor = (obj?.fillColor)!
            expo.position = (obj?.position)!
            expo.targetNode = self
            childNode(withName: "barrierLine")?.addChild(expo)
            obj?.isHidden = true
            
            // Change Player color
            let randomColor = colorsArray.randomItem()
            player.particle.particleColor = randomColor
            player.node.changeColorTo(randomColor, dur: 0.3)

            // Renable checking for collisions
            self.run(.wait(forDuration: 0.5)) {
                self.canCheck = true
            }
            
        }
        
        canCheck = false
        
        if obj?.fillColor == player.node.color || player.god {
            //print("Player color matches barrier.")
            
            // Destroying barrier
            destroyBarrier()

        } else {
            //print("Wrong contact")
            
            if player.shield {
                
                // Destroy barrier
                destroyBarrier()

                // Remove shield:
                player.node.childNode(withName: "shieldParticle")?.run(.fadeOut(withDuration: 0.2), completion: {
                    self.player.node.childNode(withName: "shieldParticle")?.removeFromParent()
                    self.player.shield = false
                })

            } else {
                killPlayer()
            }
            
        }
        
    } // End of checkObj()
    
    
}
