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

class TouchableRight : SKShapeNode
{
    open var onClickAction: ((TouchableRight)->Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        onClickAction!(self)
    }
}
class TouchableLeft : SKShapeNode
{
    open var onClickAction: ((TouchableLeft)->Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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


    func movePlayer(_ direction : Int){ //1 to right, 2 to left

        let angle: CGFloat = 0.3
        let dur = 0.2

        let RoR = SKAction.sequence(([.rotate(toAngle: -angle, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))
        let RoL = SKAction.sequence(([.rotate(toAngle: angle, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))

        if direction == 1 {
            switch player.position.x {
            case -(screenDiv * 2):
                player.run(.moveTo(x: -screenDiv, duration: dur))
                playerPOS = 2
                player.run(RoR)

            case -(screenDiv):
                player.run(.moveTo(x: 0, duration: dur))
                playerPOS = 3
                player.run(RoR)

            case 0:
                player.run(.moveTo(x: screenDiv, duration: dur))
                playerPOS = 4
                player.run(RoR)

            case (screenDiv):
                player.run(.moveTo(x: screenDiv * 2, duration: dur))
                playerPOS = 5
                player.run(RoR)

            case (screenDiv * 2):       print("can't move further")

            default: print("nil")
            }
        }
        if direction == 2 {
            switch player.position.x {
            case -(screenDiv * 2):      print("can't move further")
            case -(screenDiv):
                player.run(.moveTo(x: -(screenDiv * 2), duration: dur))
                playerPOS = 1
                player.run(RoL)

            case 0:
                player.run(.moveTo(x: -screenDiv, duration: dur))
                playerPOS = 2
                player.run(RoL)

            case (screenDiv):
                player.run(.moveTo(x: 0, duration: dur))
                playerPOS = 3
                player.run(RoL)

            case (screenDiv * 2):
                player.run(.moveTo(x: screenDiv, duration: dur))
                playerPOS = 4
                player.run(RoL)


            default: print("nil")
            }
        }

    }


    func addSwipes(){

        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(gesture:)))
            gesture.direction = direction
            self.view?.addGestureRecognizer(gesture)
        }

    }

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {

        switch gesture.direction {
        case UISwipeGestureRecognizer.Direction.left:
            movePlayer(2)

        case UISwipeGestureRecognizer.Direction.right:
            movePlayer(1)

        default:
            print("other swipe")
        }
    }

    /////TAP FUNCS (2)


    func rightTap(){
        let angle: CGFloat = 0.4
        let dur = 0.3

        let RoR = SKAction.sequence(([.rotate(toAngle: -angle, duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))
        let rRoR = SKAction.sequence(([.rotate(toAngle: -(angle*3), duration: dur/2),.rotate(toAngle: 0, duration: dur/2)]))

        if died == false {
            switch playerPOS {
            case 1:
                player.run(.moveTo(x: -screenDiv, duration: dur))
                playerPOS = 2
                player.run(RoR)
                playerParticle.run(rRoR)

            case 2:
                player.run(.moveTo(x: 0, duration: dur))
                playerPOS = 3
                player.run(RoR)
                playerParticle.run(rRoR)

            case 3:
                player.run(.moveTo(x: screenDiv, duration: dur))
                playerPOS = 4
                player.run(RoR)
                playerParticle.run(rRoR)

            case 4:
                player.run(.moveTo(x: screenDiv * 2, duration: dur))
                playerPOS = 5
                player.run(RoR)
                playerParticle.run(rRoR)

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

        if died == false{
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
