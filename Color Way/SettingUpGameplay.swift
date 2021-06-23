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

import Spring
import SwiftyUserDefaults


extension DefaultsKeys {
     var highScore: DefaultsKey<Int> { .init("highScore", defaultValue: 0) }
     var selectedSkin: DefaultsKey<String?> { .init("selectedSkin") }
     var coinsOwned: DefaultsKey<Int> { .init("coinsOwned", defaultValue: 0) }
     var lockedSkins: DefaultsKey<[Int]?> { .init("lockedSkins")}
    
}


extension GameScene {
    
    func setStartScreen() {
        // Add snowing particle to startscreen
        snowing.targetNode = self
        snowing.position.y = displaySize.height / 2
        addChild(snowing)
        
        // Setup game logo
        logo1.frame.size = CGSize(width: logo1.frame.size.width * 0.7,
                                  height: logo1.frame.size.height * 0.7)
        logo1.center.x = view!.center.x
        logo1.center.y = displaySize.height / 5
        
        logo2.frame.size = CGSize(width: logo2.frame.size.width * 0.7,
                                  height: logo2.frame.size.height * 0.7)
        logo2.center.x = view!.center.x
        logo2.center.y = displaySize.height / 5
        view!.addSubview(self.logo1)
        view!.addSubview(self.logo2)
        
        // Setup play button
        btnStart.center.x = view!.center.x
        btnStart.center.y = view!.center.y * 1.5
        btnStart.onClickAction = {
            (button) in
            self.startGame()
        }
        btnStart.color = clrMint
        view!.addSubview(btnStart)
        
        // Setup the player selection view
        setCollectionView()
        view!.addSubview(playerCollectionView)
        
        // Setup background for player selection view
        cellBackground.setScale(0.5)
        cellBackground.alpha = 0.7
        cellBackground.position = CGPoint(x: 0, y: -35)
        cellBackground.zPosition = -3
        addChild(cellBackground)
        // Sparkling particle for player cell
        cellParticle.targetNode = self
        cellParticle.position.y = -23
        
        
        //- ANIMATIONS:
        logo1.animation = "squeezeRight"
        logo2.animation = "squeezeLeft"
        
        logo1.delay = 0.2
        logo2.delay = 0.7
        
        btnStart.animation = "zoomIn"
        coinImage.animation = "squeezeLeft"
        coinsLabel.animation = "squeezeLeft"
        
        btnStart.isHidden = true
        coinImage.alpha = 0
        coinsLabel.alpha = 0
        cellLabel.alpha = 0
        playerCollectionView.alpha = 0
        cellBackground.isHidden = true
        
        logo1.animate()
        logo2.animateNext(completion: {
            [self] in
            
            cellBackground.isHidden = false
            playerCollectionView.fadeIn()
            cellLabel.fadeIn()
            addChild(cellParticle)

            coinImage.animate()
            coinsLabel.animate()
            btnStart.isHidden = false
            btnStart.animate()
                
            })
        //- END OF ANIMATIONS
    }
    
    
    func setBgLines(){
        var bgLines = Array(repeating: SKShapeNode(), count: 4)
        
        for i in 0...3 {
            let refX = -self.frame.maxX + (displaySize.width / 5) * CGFloat(i+1)
            bgLines[i] = SKShapeNode(rect: CGRect(x: 0, y: -self.frame.maxY, width: 2.5, height: displaySize.height))
            bgLines[i].position.x = refX - 1.25
            bgLines[i].strokeColor = .clear
            bgLines[i].fillColor = .gray
            bgLines[i].alpha = 0.04
            bgLines[i].zPosition = -2
            addChild(bgLines[i])
        }
        
    }
    
    
    func setPlayer(){
        
        player.node.position.y = -(displaySize.height / 1.5)
        player.node.position.x = 0
        player.node.setScale(0.2)
        player.node.zPosition = 5
        player.node.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        player.phyNode.physicsBody = SKPhysicsBody(rectangleOf: player.node.size)
        player.phyNode.physicsBody?.categoryBitMask = phyCatg.playerCATG
        player.phyNode.physicsBody?.collisionBitMask = 0
        player.phyNode.physicsBody?.contactTestBitMask = phyCatg.lineCATG
        player.phyNode.physicsBody?.affectedByGravity = false
        player.phyNode.physicsBody?.isDynamic = true
        player.phyNode.position.y = player.node.frame.maxX / 1.1
        
        player.particle.targetNode = self
        player.particle.zPosition = 0
        player.particle.position.y = -(player.node.frame.height * 7)
        player.particle.particleColorSequence = nil
        
        let randomColor = colorsArray.randomItem()
        player.particle.particleColor = randomColor
        player.node.changeColorTo(randomColor, dur: 0.3)
        
        
        player.node.addChild(player.particle)
        player.node.addChild(player.phyNode)
        addChild(player.node)
    }
    
    
    func hideStartScreen(){

        btnBuy.isHidden = true
        btnStart.animation = "zoomIn"
        logo1.animation = "squeezeRight"
        logo2.animation = "squeezeLeft"

        btnStart.animateTo()
        logo1.animateTo()
        logo2.animateTo()
        
        logo1.animation = "fadeOut"
        logo2.animation = "fadeOut"
        logo1.animateTo()
        logo2.animateTo()

        cellBackground.isHidden = true
        playerCollectionView.fadeOut()
        cellLabel.fadeOut()
        
    }
    
    @objc func startGame(){
        
        player.isDead = false
        
        hideStartScreen()
        setBgLines()
        setTaps()

        lblCurrentScore.isHidden = false

        barrierNum = 0  // Set # of barriers to 0

        rain.targetNode = self
        rain.position.y = displaySize.height / 1.8

        inGamesnow.targetNode = self
        inGamesnow.position.y = (displaySize.height / 1.8)
        
        
        snowing.removeFromParent()
        player.pos = 3 // Set initial player position
        cellParticle.removeFromParent()

        player.node.texture = SKTexture(imageNamed: Defaults[\.selectedSkin]!)
        player.node.position.y = -(displaySize.height)

        player.node.run(.moveTo(y: -(displaySize.midY / 3), duration: 2)) {
            [self] in
            
            startSpawning()
            addChild(rain)
            lblCurrentScore.animation = "fadeIn"
            lblCurrentScore.animate()
            
            snowing.alpha = 0.5
            snowing.particleSpeed = 250
            snowing.resetSimulation()
            addChild(snowing)
        }
        
        
    } // End of startGame()
    
    
    func whenDead(){
        
        player.isDead = true
        lblCurrentScore.alpha = 0
        
        // - GameOver screen stuff - //
        // GAMEOVER label
        lblGO.text = "GAMEOVER"
        lblGO.font = UIFont(name: "Odin-Bold", size: 46)
        lblGO.textColor = clrWatermelon
        lblGO.sizeToFit()
        lblGO.center.x = (view?.center.x)!
        lblGO.center.y = displaySize.height / 4
        
        // Score label
        lblGOScore.text = "\(score)"
        lblGOScore.font = UIFont(name: "Odin-Bold", size: 120)
        lblGOScore.textColor = clrWhite
        lblGOScore.sizeToFit()
        lblGOScore.center.x = (view?.center.x)!
        lblGOScore.center.y = (view?.center.y)! / 1.2
        
        // Set Highscore label text
        if score >= Defaults[\.highScore] {
            Defaults[\.highScore] = score
            lblGOHiScore.text = "NEW HIGHSCORE"
        } else {
            lblGOHiScore.text = "BEST: \(Defaults[\.highScore])"
        }
        
        // Highscore label
        lblGOHiScore.font = UIFont(name: "Odin-Bold", size: 32)
        lblGOHiScore.textColor = clrWhite
        lblGOHiScore.sizeToFit()
        lblGOHiScore.center.x = (view?.center.x)!
        lblGOHiScore.center.y = (view?.center.y)! / 0.9
        
        // Go home button
        btnHome.color = clrWatermelon
        btnHome.center.x = (view?.center.x)!
        btnHome.center.y = (view?.center.y)! * 1.575
        btnHome.onClickAction = {
            (button) in
            playAgain = false
            self.restartGame()
        }
        
        // Play Again button
        btnPlayAgain.color = clrMint
        btnPlayAgain.center.x = (view?.center.x)!
        btnPlayAgain.center.y = (view?.center.y)! * 1.4
        btnPlayAgain.onClickAction = {
            (button) in
            playAgain = true
            self.restartGame()
        }
        
        // - Animations - //
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        lblGOHiScore.alpha = 0
        btnHome.alpha = 0
        
        coinImage.animation = "squeezeLeft"
        coinsLabel.animation = "squeezeLeft"
        
        run(.wait(forDuration: 0.2)) {
            [self] in
            
            view?.shake() // Shake view
            SnapshotAnim() // Flash screen white
            coinImage.animateTo()
            coinsLabel.animateTo()

            self.run(.wait(forDuration: 0.5)) {
                
                addBlur() // Add blur over scene
                
                lblGO.animation = "squeezeDown"
                lblGOScore.animation = "fadeIn"
                lblGOHiScore.animation = "fadeIn"
                btnHome.animation = "zoomIn"
                btnPlayAgain.animation = "zoomIn"
                
                lblGO.animate()
                lblGOScore.animate()
                lblGOHiScore.animate()
                btnHome.animate()
                btnPlayAgain.animate()
            }
            
        }
        // - End of Animations - //
        
        print("Player died.")
    }
    
    
    @objc func restartGame(){
        
        removeAllChildren()
        removeAllActions()
        
        for subview in (self.view?.subviews)! {
            subview.removeFromSuperview()
            
        }
                
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
