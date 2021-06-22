//
//  Swipes.swift
//  Color Way
//
//  Created by Meshal on 4/17/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


var playerPOS = 3


class TouchableNode : SKShapeNode
{
    open var onClickAction: ((TouchableNode)->Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        onClickAction!(self)
    }
}

extension GameScene{
    
    /// Places two objects that fill the screen (one covers the right half and one the left) that act as controls to move the player
    ///
    func setTaps(){

        rightBlock.position.x = displaySize.width / 4
        leftBlock.position.x = -(displaySize.width / 4)

        rightBlock.isUserInteractionEnabled = true
        leftBlock.isUserInteractionEnabled = true

        rightBlock.fillColor = .clear
        leftBlock.fillColor = .clear
        rightBlock.strokeColor = .clear
        leftBlock.strokeColor = .clear

        rightBlock.zPosition = 100
        leftBlock.zPosition = 100

        rightBlock.onClickAction = {
            (button) in
            self.tap(dir: false)
        }

        leftBlock.onClickAction = {
            (button) in
            self.tap(dir: true)
        }

        addChild(rightBlock)
        addChild(leftBlock)
    }

    
    /// Right & Left taps logic.
    ///
    /// - Parameter dir: Indicates direction (`true` for left and `false` for right).
    func tap(dir: Bool) {
        
        // Remove rotation animations
        player.removeAction(forKey: "rotatePlayer")
        playerParticle.removeAction(forKey: "rotateParticle")
        
        // Rotation angle, Rotation duration & Movement duration
        let angle: CGFloat = 0.25
        let rotDur = 0.10
        let dur = 0.3
        
        
        /// Moves the player to a certain x location
        ///
        /// - Parameter to: X location to move player to.
        func movePlayer(_ to: CGFloat) {
            playerPOS += dir ? -1 : 1
            let dirSign: CGFloat = dir ? 1 : -1
            
            // Player's rotation animation and player particle's.
            let rotateP = SKAction.sequence([.rotate(toAngle: dirSign*angle, duration: rotDur),
                                              .wait(forDuration: dur-rotDur),
                                              .rotate(toAngle: 0, duration: rotDur)])
            let rotatePP = SKAction.sequence([.rotate(toAngle: dirSign*(angle*3), duration: rotDur),
                                              .wait(forDuration: dur-rotDur),
                                              .rotate(toAngle: 0, duration: rotDur)])
            
            player.run(.moveTo(x: to, duration: dur)) // Move
            player.run(rotateP, withKey: "rotatePlayer") // Rotate
            playerParticle.run(rotatePP, withKey: "rotateParticle") // Rotate
        }
        
        
        // Deciding where to move player
        if !playerDead {
            switch playerPOS {
            case 1:
                //                       {left tap} : {right tap}
                dir ? (print("can't move further")) : (movePlayer(-screenDiv))

            case 2:
                dir ? (movePlayer(-(screenDiv * 2))) : (movePlayer(0))

            case 3:
                dir ? (movePlayer(-screenDiv)) : (movePlayer(screenDiv))

            case 4:
                dir ? (movePlayer(0)) : (movePlayer(screenDiv * 2))

            case 5:
                dir ? (movePlayer(screenDiv)) : (print("can't move further"))

            default:
                print("ERROR: couldn't process tap")
            }
        }
        
    }
    
}
