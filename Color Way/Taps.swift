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
        
        // Remove rotation animations when moving player to another position.
        if !((dir && player.pos == 1) || (!dir && player.pos == 5)) {
            player.node.removeAction(forKey: "rotatePlayer")
        }
        
        // Rotation angle, Rotation duration & Movement duration
        let angle: CGFloat = 0.27 //.3
        let rotDur = 0.07 //.1
        let moveDur = 0.22 //.25
        
        
        /// Moves the player to a certain x location
        ///
        /// - Parameter to: X location to move player to.
        func movePlayer(_ to: CGFloat) {
            player.pos += dir ? -1 : 1
            let dirSign: CGFloat = dir ? 1 : -1
            
            // Player's rotation animation.
            let rotateP = SKAction.sequence([.rotate(toAngle: dirSign*angle, duration: rotDur),
                                              .wait(forDuration: moveDur-rotDur),
                                              .rotate(toAngle: 0, duration: rotDur)])
            
            player.node.run(.moveTo(x: to, duration: moveDur)) // Move
            player.node.run(rotateP, withKey: "rotatePlayer") // Rotate
        }
        
        
        // Deciding where to move player
        if !player.isDead {
            switch player.pos {
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
