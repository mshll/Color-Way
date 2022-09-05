//
//  GameViewController.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var skView = SKView() // scene ref
    
    // MARK: - Set up view and load game scene

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        
        skView = view as! SKView
        
        // Initialize splash view
        let splashView = RevealingSplashView(iconImage: UIImage(named: "mshlLogo")!,
                                             iconInitialSize: CGSize(width: 130, height: 110),
                                             backgroundColor: clrBg)
        
        view.addSubview(splashView)
    
        // Starts animation
        splashView.startAnimation()
        
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.scaleMode = .aspectFill
            scene.size = view.bounds.size
            skView.ignoresSiblingOrder = true

            skView.showsNodeCount = DEBUG
            skView.showsFields = DEBUG
            skView.showsFPS = DEBUG
            skView.showsPhysics = DEBUG

            skView.presentScene(scene)
        }
    }
    
    // MARK: - Set Keyboard Input

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let gameScene = skView.scene as? GameScene
        guard let key = presses.first?.key else { return }
            
        switch key.keyCode {
        case .keyboardRightArrow:
            // If in-game control player
            if gameState == INGAME && gameScene!.rightBlock.isUserInteractionEnabled {
                gameScene?.tap(RIGHT)
                
            } else if gameState == STARTSCREEN {
                if let indexPath = gameScene!.playerCollectionView.visibleCurrentCellIndexPath {
                    // If at start screen, change skins
                    gameScene!.playerCollectionView.scrollToItem(at: IndexPath(item: indexPath.item + 1, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            
        case .keyboardLeftArrow:
            // If in-game control player
            if gameState == INGAME && gameScene!.leftBlock.isUserInteractionEnabled {
                gameScene?.tap(LEFT)
            } else if gameState == STARTSCREEN {
                if let indexPath = gameScene!.playerCollectionView.visibleCurrentCellIndexPath {
                    // If at start screen, change skins
                    gameScene!.playerCollectionView.scrollToItem(at: IndexPath(item: indexPath.item - 1, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            
        case .keyboardReturnOrEnter, .keypadEnter, .keyboardSpacebar:
            // Start game using Enter key or Spacebar
            if gameState == GAMEOVER {
                gameScene?.btnPlayAgain.click()
            } else if gameState == STARTSCREEN {
                gameScene?.btnStart.click()
            }
            
        case .keyboardEscape, .keyboardDeleteOrBackspace:
            // Go home if pressing esc or delete when at gameover screen
            if gameState == GAMEOVER {
                gameScene?.btnHome.click()
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
