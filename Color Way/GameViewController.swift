//
//  GameViewController.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import UIKit
import SpriteKit
import GameplayKit

var displaySize = UIScreen.main.bounds


class GameViewController: UIViewController {

    
    var skView = SKView()   // scene ref
    
    // MARK - Set up view and load game scene
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        
        skView = self.view as! SKView
        
        // Initialize splash view
        let splashView = RevealingSplashView(iconImage: UIImage(named: "mshlLogoCircle")!,
                                                      iconInitialSize: CGSize(width: 130, height: 110),
                                                      backgroundColor: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.00))
        
        splashView.animationType = .woobleAndZoomOut
        self.view.addSubview(splashView)
    
        // Starts animation
        splashView.startAnimation()
        
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            displaySize = UIScreen.main.bounds // Update display size just in case
            
            scene.scaleMode = .aspectFill
            scene.size = view.bounds.size
            skView.ignoresSiblingOrder = true

            let debug = false
            skView.showsNodeCount = debug
            skView.showsFields = debug
            skView.showsFPS = debug
            skView.showsPhysics = debug

            skView.presentScene(scene)
            
        }
        
        
    }
    
    // MARK - Get Keyboard Input (Left & Right Arrows for movement)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let gameScene = skView.scene as? GameScene
        guard let key = presses.first?.key else { return }
            
        switch key.keyCode {
                            
        case .keyboardRightArrow:
            if (!gameScene!.player.isDead) {
                gameScene?.tap(dir: false)
            }
            
        case .keyboardLeftArrow:
            if (!gameScene!.player.isDead) {
                gameScene?.tap(dir: true)
            }
            
        default:
            super.pressesBegan(presses, with: event)
        }
    }
    

    override var shouldAutorotate: Bool {
        return false
    }
        
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
