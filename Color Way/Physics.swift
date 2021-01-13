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

import DynamicColor
import ChameleonFramework
import EasySocialButton
import Spring
import AnimatedCollectionViewLayout
import SwiftyUserDefaults
import TCProgressBar
import GTProgressBar
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

        if (first.categoryBitMask == phyCatg.playerCATG && second.categoryBitMask == phyCatg.lineCATG) {

            if canCheck == true {
            if playerPOS == 1 {
                checkObj(second.node as? SKShapeNode,"B1")

            } else if playerPOS == 2 {
                checkObj(second.node as? SKShapeNode,"B2")

            } else if playerPOS == 3 {
                checkObj(second.node as? SKShapeNode,"B3")

            } else if playerPOS == 4 {
                checkObj(second.node as? SKShapeNode,"B4")

            } else if playerPOS == 5 {
                checkObj(second.node as? SKShapeNode,"B5")

            }
           }
        }

        if (first.categoryBitMask == phyCatg.playerCATG && second.categoryBitMask == phyCatg.coinCATG){

            switch second.node!.name{
            case loots[0]:
                print("YOU GET NOTHING")

            case loots[1]:
                let secondNode = second.node!.copy() as! SKSpriteNode
                secondNode.removeAllActions()
                second.node!.alpha = 0
                secondNode.run(.sequence([.scale(by: 2, duration: 0.05),
                                          .scale(to: 0, duration: 0.2)]))
                secondNode.run(.move(to: convertPoint(fromView: coinImage.center), duration: 0.2)) {
                    secondNode.removeFromParent()
                    self.coinsLabel.animation = "pop"
                    self.coinsLabel.animate()
                }
                addChild(secondNode)
                Defaults[\.coinsOwned] += 1
                coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")


            case loots[2]:
                //REMOVES ALREADY EXISTING SHIELD
                player.childNode(withName: "shieldParticle")?.removeFromParent()
                //~
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

            default: print("nil")
            }


        }
    }
    
    func checkObj(_ n : SKShapeNode?, _ s : String){
        canCheck = false
        //let node = childNode(withName: "BLine")?.childNode(withName: "\(s)-\(Bnum - 2)")?.copy() as? SKShapeNode
        
        if n?.fillColor == player.color {
            print("MATCH")
            
            
            prog += 1
            
            let lvlbarrierif = Double(Defaults[\.levelBarriers])
            
            levelProg.animateTo(progress: CGFloat(self.prog / lvlbarrierif))
            
            delayCode(0.5){
                if (self.prog / lvlbarrierif) >= 1{
                    
                    //WHEN LEVELING UP
                    self.levelProg.animateTo(progress: 0)
                    self.prog = 0
                    self.checkLvl()
                    Defaults[\.level] += 1
                    self.levellbl.text = "level \(Defaults[\.level])"
                    self.levellbl.sizeToFit()
                    
                }
                
            }
            
            
            AddingScore()
            
            
            
            
            
            let expo = SKEmitterNode(fileNamed: "explosionParticle.sks")!
            expo.particleColorSequence = nil
            expo.particleColor = (n?.fillColor)!
            expo.position = (n?.position)! //(childNode(withName: "BLine")?.childNode(withName: "\(s)-\(Bnum - 2)")?.position)!
            expo.targetNode = self
            childNode(withName: "BLine")?.addChild(expo)
            //childNode(withName: "BLine")?.childNode(withName: "\(s)-\(Bnum - 2)")?.isHidden = true
            n?.isHidden = true
            
            playerParticle.particleColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))]
            player.changeColorTo(playerParticle.particleColor, dur: 0.3)
            
            delayCode(0.5){
                self.canCheck = true
        }
            
            
        } else {
            print("WRONG")
            
            if haveShield == true{
                
                let expo = SKEmitterNode(fileNamed: "explosionParticle.sks")!
                expo.particleColorSequence = nil
                expo.particleColor = (n?.fillColor)!
                expo.position = (n?.position)! //(childNode(withName: "BLine")?.childNode(withName: "\(s)-\(Bnum - 2)")?.position)!
                expo.targetNode = self
                childNode(withName: "BLine")?.addChild(expo)
                //childNode(withName: "BLine")?.childNode(withName: "\(s)-\(Bnum - 2)")?.isHidden = true
                n?.isHidden = true
                
                playerParticle.particleColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))]
                player.changeColorTo(playerParticle.particleColor, dur: 0.3)
                
                delayCode(0.5){
                    self.canCheck = true
                }
                
                //remove shield:
                player.childNode(withName: "shieldParticle")?.run(.fadeOut(withDuration: 0.2), completion: {
                    self.player.childNode(withName: "shieldParticle")?.removeFromParent()
                    self.haveShield = false
                })
                
                
                
            } else{
                enumerateChildNodes(withName: "BLine") { (node, error) in
                    node.speed = 0
                    self.removeAction(forKey: "Spawning")
                }
                enumerateChildNodes(withName: "CoinLine") { (node, error) in
                    node.speed = 0
                    self.removeAction(forKey: "CoinSpawning")
                }
                
                
                let playerexplo = SKEmitterNode(fileNamed: "playerExplo.sks")!
                playerexplo.targetNode = self
                playerexplo.particleColorSequence = nil
                playerexplo.zPosition = player.zPosition
                playerexplo.particleColor = playerParticle.particleColor
                player.run(.fadeOut(withDuration: 0.1))
                player.addChild(playerexplo)
                playerParticle.removeFromParent()
                
                
                whenDied()
            }
            
        }
    }
    
    
}
