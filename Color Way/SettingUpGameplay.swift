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
     var level: DefaultsKey<Int> { .init("level", defaultValue: 0) }
     var levelBarriers: DefaultsKey<Int> { .init("levelBarriers", defaultValue: 0) }
    
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

        self.btnStart.animateTo()


        self.selectedCell.isHidden = true
        self.playerCollectionView.fadeOut()
        self.CellsLabel.fadeOut()
        
        
    }
    
    @objc func startGame(){
        setBackground()
        hideStartScreen()
        setTaps()

        levelProg.alpha = 1


        ///Setting level progress:
        lblScore.isHidden = true

        Bnum = 0

        rain.targetNode = self
        rain.position.y = displaySize.height / 1.8

        inGamesnow.targetNode = self
        inGamesnow.position.y = (displaySize.height / 1.8)
        snowing.removeFromParent()
        playerPOS = 3
        cellParticle.removeFromParent()

        player.texture = SKTexture(imageNamed: Defaults[\.selectedSkin]!)

        player.position.y = -(displaySize.height / 1.5)

        player.run(.moveTo(y: -(displaySize.midY / 3), duration: 2)) {

            delayCode(1){
                self.startSpawning()
                self.addChild(self.rain)
                //self.addChild(self.inGamesnow)


                self.lblScore.animation = "fadeIn"
                self.lblScore.animate()


            }

        }
        
        
        
        
    }
    
    
    func whenDied(){
        
        died = true
        gameOn = false
        lblScore.alpha = 0
        levelProg.alpha = 0
        
        
        lblGO.text = "GAMEOVER"
        lblGO.font = UIFont(name: "Odin-Bold", size: 46)
        lblGO.textColor = .flatWatermelon()
        lblGO.sizeToFit()
        lblGO.center.x = (view?.center.x)!
        lblGO.center.y = displaySize.height / 4
        
        
        lblGOScore.text = "\(Defaults[\.level])"
        lblGOScore.font = UIFont(name: "Odin-Bold", size: 120)
        lblGOScore.textColor = .flatWhite()
        lblGOScore.sizeToFit()
        lblGOScore.center.x = (view?.center.x)!
        lblGOScore.center.y = (view?.center.y)! / 1.2
        
        
        btnHome.color = .flatWatermelon()
        btnHome.center.x = (view?.center.x)!
        btnHome.center.y = (view?.center.y)! * 1.4
        btnHome.onClickAction = {
            (button) in
            
            self.restartGame()
            
        }
        
        
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        btnHome.alpha = 0
        
        
        
        
        //DEATH ANIMATIONS:
        delayCode(0.5){
            self.coinImage.animation = "squeezeLeft"
            self.coinsLabel.animation = "squeezeLeft"
            
            self.view?.shake()
            //self.SnapshotAnim()
            self.coinImage.animateTo()
            self.coinsLabel.animateTo()
        }
        delayCode(0.8){
            
            self.addBlur()
            
            self.lblGO.animation = "squeezeDown"
            self.lblGOScore.animation = "fadeIn"
            self.btnHome.animation = "zoomIn"
            
            delayCode(0.3){
                
                self.lblGO.animate()
                self.lblGOScore.animate()
                self.btnHome.animate()
                
            }
            
            
            
        }
        
        print("PLAYER DEAD!!!")
    }
    
    
    @objc func restartGame(){
        
        
        self.removeAllChildren()
        self.removeAllActions()
        
        for subview in (self.view?.subviews)! {
            subview.removeFromSuperview()
            
        }
        
        
        print("RESTART GAME????")
        let skView = self.view!
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            scene.size = (view?.bounds.size)!
            
            skView.presentScene(scene)
        }
        
        
        
    }
    
    @objc func AddingScore(){
        score += 1
        lblScore.text = "\(score)"
        lblScore.sizeToFit()
        lblScore.center.x = (self.view?.center.x)!
        lblScore.animation = "morph"
        lblScore.duration = 0.3
        lblScore.animateNext(completion: {})
        lblScore.animate()
        
    }
    
    func checkLvl(){
        
        if Defaults[\.level] > CInt(Defaults[\.levelBarriers]){
            Defaults[\.levelBarriers] += 5
        }
        
    }
    
    
    
}
