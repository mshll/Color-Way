//
//  SettingUpGameplay.swift
//  Color Way
//
//  Created by Meshal Almutairi on 5/6/20.
//  Copyright © 2020 Meshal Almutairi. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

//Pods
import ChameleonFramework
import DynamicColor
import Spring
import SwiftyUserDefaults


extension DefaultsKeys {
     var highScore: DefaultsKey<Int> { .init("highScore", defaultValue: 0) }
     var selectedSkin: DefaultsKey<String?> { .init("selectedSkin") }
     var coinsOwned: DefaultsKey<Int> { .init("coinsOwned", defaultValue: 0) }
     var lockedSkins: DefaultsKey<[Int]?> { .init("lockedSkins")}
    
}


extension GameScene {
    
    func setBackground(){
        
        let bgLine1 = SKShapeNode(rect: CGRect(x: 0, y: -self.frame.maxY, width: 2.5, height: displaySize.height))
        bgLine1.position.x = (-self.frame.maxX + (displaySize.width / 5) * 1) - 1.25
        bgLine1.strokeColor = .clear
        bgLine1.fillColor = .gray
        bgLine1.alpha = 0.03
        bgLine1.zPosition = -2
        
        
        let bgLine2 = SKShapeNode(rect: CGRect(x: 0, y: -self.frame.maxY, width: 2.5, height: displaySize.height))
        bgLine2.position.x = (-self.frame.maxX + (displaySize.width / 5) * 2) - 1.25
        bgLine2.strokeColor = .clear
        bgLine2.fillColor = bgLine1.fillColor
        bgLine2.alpha = bgLine1.alpha
        bgLine2.zPosition = -2
        
        let bgLine3 = SKShapeNode(rect: CGRect(x: 0, y: -self.frame.maxY, width: 2.5, height: displaySize.height))
        bgLine3.position.x = (-self.frame.maxX + (displaySize.width / 5) * 3) - 1.25
        bgLine3.strokeColor = .clear
        bgLine3.fillColor = bgLine1.fillColor
        bgLine3.alpha = bgLine1.alpha
        bgLine3.zPosition = -2
        
        let bgLine4 = SKShapeNode(rect: CGRect(x: 0, y: -self.frame.maxY, width: 2.5, height: displaySize.height))
        bgLine4.position.x = (-self.frame.maxX + (displaySize.width / 5) * 4) - 1.25
        bgLine4.strokeColor = .clear
        bgLine4.fillColor = bgLine1.fillColor
        bgLine4.alpha = bgLine1.alpha
        bgLine4.zPosition = -2
        
        
        
        addChild(bgLine1)
        addChild(bgLine2)
        addChild(bgLine3)
        addChild(bgLine4)
    }
    
    func setPlayer(){
        
        
        player.position.y = -(displaySize.height / 1.5) //-(displaySize.midY / 2)
        player.position.x = 0
        player.setScale(0.2)
        player.zPosition = 5
        player.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        playerPHY.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        playerPHY.physicsBody?.categoryBitMask = phyCatg.playerCATG
        playerPHY.physicsBody?.collisionBitMask = 0
        playerPHY.physicsBody?.contactTestBitMask = phyCatg.lineCATG
        playerPHY.physicsBody?.affectedByGravity = false
        playerPHY.physicsBody?.isDynamic = true
        
        playerPHY.position.y = player.frame.maxX / 1.1
        
        player.addChild(playerPHY)
        addChild(player)
        
        
        
        playerParticle.targetNode = self
        playerParticle.zPosition = 0
        playerParticle.position.y = -(player.frame.height * 7)
        playerParticle.particleColorSequence = nil
        
        
        playerParticle.particleColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))]
        player.changeColorTo(playerParticle.particleColor, dur: 0.3)
        
        
        player.addChild(playerParticle)
    }
    
    func setStartScreen(){
        
        
    }
    
    func hideStartScreen(){

        btnStart.animation = "zoomIn"
        logo1.animation = "squeezeRight"
        logo2.animation = "squeezeLeft"



        btnBuy.isHidden = true

        self.logo1.animateTo()
        self.logo2.animateTo()

        self.btnStart.animateToNext {
            self.logo1.isHidden = true
            self.logo2.isHidden = true
        }


        self.cellBackground.isHidden = true
        self.playerCollectionView.fadeOut()
        self.CellsLabel.fadeOut()
        
        
    }
    
    @objc func startGame(){
        
        hideStartScreen()
        setBackground()
        setTaps()

        lblCurrentScore.isHidden = false

        barrierNum = 0  // Set # of barriers to 0

        rain.targetNode = self
        rain.position.y = displaySize.height / 1.8

        inGamesnow.targetNode = self
        inGamesnow.position.y = (displaySize.height / 1.8)
        
        
        snowing.removeFromParent()
        playerPOS = 3
        cellParticle.removeFromParent()

        player.texture = SKTexture(imageNamed: Defaults[\.selectedSkin]!)

        player.position.y = -(displaySize.height)

        player.run(.moveTo(y: -(displaySize.midY / 3), duration: 2)) {

                self.startSpawning()
                self.addChild(self.rain)

                self.lblCurrentScore.animation = "fadeIn"
                self.lblCurrentScore.animate()


        }
        
        
    } // End of startGame()
    
    
    func whenDead(){
        
        if score >= Defaults[\.highScore] {
            Defaults[\.highScore] = score
        }
        
        playerDead = true
        gameOn = false
        lblCurrentScore.alpha = 0
        
        
        lblGO.text = "GAMEOVER"
        lblGO.font = UIFont(name: "Odin-Bold", size: 46)
        lblGO.textColor = .flatWatermelon()
        lblGO.sizeToFit()
        lblGO.center.x = (view?.center.x)!
        lblGO.center.y = displaySize.height / 4
        
        
        lblGOScore.text = "\(score)"
        lblGOScore.font = UIFont(name: "Odin-Bold", size: 120)
        lblGOScore.textColor = .flatWhite()
        lblGOScore.sizeToFit()
        lblGOScore.center.x = (view?.center.x)!
        lblGOScore.center.y = (view?.center.y)! / 1.2
        
        lblGOHiScore.text = "Best: \(Defaults[\.highScore])"
        lblGOHiScore.font = UIFont(name: "Odin-Bold", size: 32)
        lblGOHiScore.textColor = .flatWhite()
        lblGOHiScore.sizeToFit()
        lblGOHiScore.center.x = (view?.center.x)!
        lblGOHiScore.center.y = (view?.center.y)! / 0.9
        
        
        btnHome.color = .flatWatermelon()
        btnHome.center.x = (view?.center.x)!
        btnHome.center.y = (view?.center.y)! * 1.4
        btnHome.onClickAction = {
            (button) in
            
            self.restartGame()
            
        }
        
        
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        lblGOHiScore.alpha = 0
        btnHome.alpha = 0
        
        
        self.coinImage.animation = "squeezeLeft"
        self.coinsLabel.animation = "squeezeLeft"
            
        self.view?.shake()
        //self.SnapshotAnim()
        self.coinImage.animateTo()
        self.coinsLabel.animateTo()


        delayCode(0.1){
            
            self.addBlur()
            
            self.lblGO.animation = "squeezeDown"
            self.lblGOScore.animation = "fadeIn"
            self.lblGOHiScore.animation = "fadeIn"
            self.btnHome.animation = "zoomIn"
            
            self.lblGO.animate()
            self.lblGOScore.animate()
            self.lblGOHiScore.animate()
            self.btnHome.animate()
                
            
            
            
        }
        
        print("Player died.")
    }
    
    
    @objc func restartGame(){
        
        
        self.removeAllChildren()
        self.removeAllActions()
        
        for subview in (self.view?.subviews)! {
            subview.removeFromSuperview()
            
        }
                
        print("Restarting Game...")
        let skView = self.view!
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            scene.size = (view?.bounds.size)!

            skView.presentScene(scene)
        }
        
    }
    
    
    @objc func AddingScore(){
        score += 1
        lblCurrentScore.text = "\(score)"
        lblCurrentScore.sizeToFit()
        lblCurrentScore.center.x = (self.view?.center.x)!
        lblCurrentScore.animation = "morph"
        lblCurrentScore.duration = 0.3
        lblCurrentScore.animateNext(completion: {})
        lblCurrentScore.animate()
        
    }
    
    
}
