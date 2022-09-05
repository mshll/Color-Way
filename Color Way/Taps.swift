//
//  Swipes.swift
//  Color Way
//
//  Created by Meshal on 4/17/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class TouchableNode: SKShapeNode {
    open var onClickAction: ((TouchableNode) -> Void)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onClickAction!(self)
    }
}

extension GameScene {
    /// Places two objects that fill the screen (one covers the right half and one the left) that act as controls to move the player
    ///
    func setTaps() {
        rightBlock.position.x = displaySize.width / 4
        leftBlock.position.x = -(displaySize.width / 4)

        rightBlock.isUserInteractionEnabled = false
        leftBlock.isUserInteractionEnabled = false

        rightBlock.fillColor = .clear
        leftBlock.fillColor = .clear
        rightBlock.strokeColor = .clear
        leftBlock.strokeColor = .clear

        rightBlock.zPosition = 100
        leftBlock.zPosition = 100

        rightBlock.onClickAction = {
            _ in
            self.tap(RIGHT)
        }

        leftBlock.onClickAction = {
            _ in
            self.tap(LEFT)
        }

        addChild(rightBlock)
        addChild(leftBlock)
    }

    /// Right & Left taps logic.
    ///
    /// - Parameter dir: Indicates direction (`true` for left and `false` for right).
    func tap(_ dir: Bool) {
        // Rotation angle, Rotation duration & Movement duration
        let angle: CGFloat = 0.27
        let moveDur = 0.22

        /// Moves the player to a certain x location
        ///
        /// - Parameter to: X location to move player to.
        func movePlayer(_ to: CGFloat) {
            // Update the player's position
            player.pos += dir ? -1 : 1
            let dirSign: CGFloat = dir ? 1 : -1

            // Rotate the player when the player changes position.
            player.node.run(.rotate(toAngle: dirSign * angle, duration: moveDur / 2))

            // Create a sequence of actions to smoothly move the player to the target position and rotate it back.
            let moveP = SKAction.sequence([
                .move(to: CGPoint(x: to, y: player.node.position.y), duration: moveDur), // Move the player to the target position
                .rotate(toAngle: 0, duration: moveDur / 2) // Rotate it the player back to a straight angle
            ])

            // Remove any pending actions on the player's character before running the new movement animation.
            player.node.removeAction(forKey: "movePlayer")
            // Run the movement animation.
            player.node.run(moveP, withKey: "movePlayer")
        }

        // Deciding where to move player
        if gameState == INGAME {
            switch player.pos {
            case 1:
                //                       {left tap} : {right tap}
                dir ? print("can't move further") : movePlayer(-screenDiv)

            case 2:
                dir ? movePlayer(-(screenDiv * 2)) : movePlayer(0)

            case 3:
                dir ? movePlayer(-screenDiv) : movePlayer(screenDiv)

            case 4:
                dir ? movePlayer(0) : movePlayer(screenDiv * 2)

            case 5:
                dir ? movePlayer(screenDiv) : print("can't move further")

            default:
                print("ERROR: couldn't process tap")
            }
        }
    }
}
