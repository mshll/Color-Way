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
            self.rightTap()
        }

        leftBlock.onClickAction = {
            (button) in
            self.leftTap()
        }

        addChild(rightBlock)
        addChild(leftBlock)
    }

    
    // - Right & Left taps logic -
    func rightTap(){
        let angle: CGFloat = 0.4
        let dur = 0.3

        let rotatePlayer = SKAction.sequence(([.rotate(toAngle: -angle, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))
        let rotatePlayerParticle = SKAction.sequence(([.rotate(toAngle: -(angle*3), duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))

        if playerDead == false {
            switch playerPOS {
            case 1:
                player.run(.moveTo(x: -screenDiv, duration: dur))
                playerPOS = 2
                player.run(rotatePlayer)
                playerParticle.run(rotatePlayerParticle)

            case 2:
                player.run(.moveTo(x: 0, duration: dur))
                playerPOS = 3
                player.run(rotatePlayer)
                playerParticle.run(rotatePlayerParticle)

            case 3:
                player.run(.moveTo(x: screenDiv, duration: dur))
                playerPOS = 4
                player.run(rotatePlayer)
                playerParticle.run(rotatePlayerParticle)

            case 4:
                player.run(.moveTo(x: screenDiv * 2, duration: dur))
                playerPOS = 5
                player.run(rotatePlayer)
                playerParticle.run(rotatePlayerParticle)

            case 5:       print("can't move further")

            default: print("nil")
            }
        }

    }

    func leftTap(){
        let angle: CGFloat = 0.4
        let dur = 0.3

        let RoL = SKAction.sequence(([.rotate(toAngle: angle, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))
        let rRoL = SKAction.sequence(([.rotate(toAngle: angle*3, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))

        if playerDead == false{
            switch playerPOS {
            case 1:      print("can't move further")
            case 2:
                player.run(.moveTo(x: -(screenDiv * 2), duration: dur))
                playerPOS = 1
                player.run(RoL)
                playerParticle.run(rRoL)

            case 3:
                player.run(.moveTo(x: -screenDiv, duration: dur))
                playerPOS = 2
                player.run(RoL)
                playerParticle.run(rRoL)


            case 4:
                player.run(.moveTo(x: 0, duration: dur))
                playerPOS = 3
                player.run(RoL)
                playerParticle.run(rRoL)


            case 5:
                player.run(.moveTo(x: screenDiv, duration: dur))
                playerPOS = 4
                player.run(RoL)
                playerParticle.run(rRoL)



            default: print("nil")
            }
        }

    }
    
}
