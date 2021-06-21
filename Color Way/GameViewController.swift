//
//  GameViewController.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import UIKit
import SpriteKit
import GameplayKit

let displaySize: CGRect = UIScreen.main.bounds


class GameViewController: UIViewController {

    
    var skView = SKView()   // scene ref
    
    // MARK - Set up view and load game scene
    override func viewDidLoad() {
        super.viewDidLoad()

        
        skView = self.view as! SKView
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.scaleMode = .aspectFill
            scene.size = view.bounds.size
            skView.ignoresSiblingOrder = true
            
            skView.showsNodeCount = false
            //skView.showsFields = true
            skView.showsFPS = false
            //skView.showsPhysics = true
            
            
            skView.presentScene(scene)
        }
        
    }
    
    // MARK - Get Keyboard Input (Left & Right Arrows for movement)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let gameScene = skView.scene as? GameScene
        guard let key = presses.first?.key else { return }
            
        switch key.keyCode {
                            
        case .keyboardRightArrow:
            if ((gameScene?.gameOn) != nil) {
                gameScene?.rightTap()
            }
            
        case .keyboardLeftArrow:
            if ((gameScene?.gameOn) != nil) {
                gameScene?.leftTap()
            }
            
        default:
            super.pressesBegan(presses, with: event)
        }
    }
    

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
