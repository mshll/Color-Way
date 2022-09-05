//
//  GameScene.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import GameplayKit
import LNZCollectionLayouts
import Lottie
import Spring
import SpriteKit
import SwiftyUserDefaults

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Player structure
    struct Player {
        var node = SKSpriteNode(imageNamed: "playerSkin1")
        let particle = SKEmitterNode(fileNamed: "playerParticle.sks")!
        var phyNode = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
        var skins = Array(repeating: "", count: 20)
        var pos = 3
        var shield = false
        var god = false
    }
    
    // MARK: Variables  //
    
    var player = Player() // initalize player
    var spawnDur: CGFloat = 2.0 // Interval between each barrier/loot spawn
    var bgRadial = SKSpriteNode() // Radial background

    // Set up player selection view
    let cellBackground = SKSpriteNode(imageNamed: "greenBlur") // Skin cell background
    var playerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: UICollectionViewFlowLayout())
    var lastValidPlayerIndex: Int = 0
    let cellParticle = SKEmitterNode(fileNamed: "sparkleStar.sks")!
    let cellLabel = UILabel() // Label that shows which cell you're on
    let btnBuy = cButton(btitle: "\(unlockPrice)")
    var justLaunched = true // Indicates if the game just launched or not [Used to view playerCollectionView correctly]
    
    // Taps
    var rightBlock = TouchableNode()
    var leftBlock = TouchableNode()

    // Particles
    let snowing = SKEmitterNode(fileNamed: "snowingParticle.sks")!
    let rain = SKEmitterNode(fileNamed: "rainParticle.sks")!
    let inGamesnow = SKEmitterNode(fileNamed: "inGamesnow.sks")!
    
    // The barriers and loot movement stuff
    var barriersLine = SKNode()
    var lootLine = SKNode()
    var barrierNum = 0 // Indicates how many barriers spawned so far
    var vagueClrDur = TimeInterval()
    // the move-remove actions
    var distanceBarr: CGFloat = 0.0
    var moveLine = SKAction()
    var moveRemoveAction = SKAction()
    
    // Coins label and image
    let coinsLabel = SpringLabel()
    let bestLabel = SpringLabel()
    
    // Dividing the screen to 5 parts
    var screenSection: [CGFloat] = []
    
    // Barriers colors
    var colorsArray: [UIColor] = [clrSkyBlue, clrPurple, clrMint, clrWatermelon, clrYellow]
    var randomColor = clrSkyBlue // Random color to change player to everytime
    
    // Indicates if collisions should be checked or not
    var canCheck: Bool = true
    var canCheckLoot: Bool = true
    
    // Game logo
    var logo1 = SpringImageView(image: UIImage(named: "gameLogo1"))
    var logo2 = SpringImageView(image: UIImage(named: "gameLogo2"))
    
    // Start button
    var btnStart = cButton(btitle: "Play")
    var btnInfo = cButton(btitle: "i")
    var secretCounter1 = 0
    var secretCounter2 = 0
    
    // Keeping track of current score
    var score: Int = 0
    
    // GameOver screen variables
    let btnHome = cButton(btitle: "Home")
    let btnPlayAgain = cButton(btitle: "Play Again")
    let lblGO = SpringLabel()
    let lblGOScore = SpringLabel()
    let lblCurrentScore = SpringLabel() // Current score label in-game
    
    // Loot stuff
    let loots = ["nil", "coin", "shield", "skull", "double"] // 'double' unused
    let lootWeight = [73, 20, 2, 5, 0] // Weight for loot [i] to be chosen :: (sum should = 100)
    let lootMax = [5, 3, 1, 2, 0] // Max # of loot [i] in a line (Can't be > 5)

    let confetti = AnimationView(name: "conf")
    //  ***  End of Variables  ***  //
    
    // MARK: didMove to view

    override func didMove(to view: SKView) {
        // Get display size of the scene
        displaySize = view.bounds
        screenDiv = (displaySize.width / 5) // Set screen divider
        screenSection = [-(screenDiv * 2), -screenDiv, 0, screenDiv, screenDiv * 2] // Divides screen to 5 spaces

        // Set Taps
        rightBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
        leftBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
        
        physicsWorld.contactDelegate = self
                
        // Set player skins names
        for i in 0 ... (player.skins.count - 1) {
            player.skins[i] = "playerSkin\(i + 1)"
        }
        
        // Initialize skins
        if Defaults[\.lockedSkins] == nil {
            Defaults[\.lockedSkins] = Array(repeating: 0, count: 20)
            Defaults[\.lockedSkins]![0] = 1 // Unlock first skin
        }
        
        backgroundColor = clrBg
        lastValidPlayerIndex = player.skins.firstIndex(of: Defaults[\.selectedSkin] ?? "playerSkin1")! // Set which index should be selected for the selection view
        
        // Setup the radial background
        bgRadial.texture = SKTexture(imageNamed: "bgRadial\(Int(arc4random_uniform(2)) + 1)")
        let bgAspectRatio = bgRadial.texture!.size().width / bgRadial.texture!.size().height
        bgRadial.anchorPoint = CGPoint(x: 0.5, y: 0)
        bgRadial.position = CGPoint(x: frame.midX, y: frame.minY )
        bgRadial.zPosition = -99
        bgRadial.size = CGSize(width: (displaySize.size.height / 1.5) * bgAspectRatio, height: displaySize.size.height / 1.5)
        bgRadial.alpha = 0
        addChild(bgRadial)
        
        // Setup player
        setPlayer()
        
        // Setup coins label
        coinsLabel.text = "999999999999999"
        coinsLabel.font = UIFont(name: "Odin-Bold", size: 24)
        coinsLabel.sizeToFit()
        coinsLabel.frame.size.height *= 2
        coinsLabel.textColor = clrYellowDark
        coinsLabel.textAlignment = .right
        coinsLabel.center.x = (displaySize.width / 1.05) - (coinsLabel.frame.size.width / 2)
        coinsLabel.center.y = (view.center.y) / 6.93
        coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")
        view.addSubview(coinsLabel)
        
        // Setup best score label
        bestLabel.text = "999999999999999"
        bestLabel.font = UIFont(name: "Odin-Bold", size: 24)
        bestLabel.sizeToFit()
        bestLabel.frame.size.height *= 2
        bestLabel.textColor = clrWhite
        bestLabel.textAlignment = .center
        bestLabel.center = view.center
        bestLabel.center.y /= 1.3
        bestLabel.set(image: UIImage(named: "crown")!, with: "\(Defaults[\.highScore])", RorL: 0)
        view.addSubview(bestLabel)
        bestLabel.alpha = 0
        
        // Preparing GameOver screen stuff
        view.addSubview(btnHome)
        view.addSubview(btnPlayAgain)
        view.addSubview(lblGO)
        view.addSubview(lblGOScore)
        btnHome.alpha = 0
        btnPlayAgain.alpha = 0
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        
        // Preparing current score label for in-game
        lblCurrentScore.text = "\(score)"
        lblCurrentScore.font = UIFont(name: "Odin-Bold", size: 58)
        lblCurrentScore.textColor = clrWhite
        lblCurrentScore.sizeToFit()
        lblCurrentScore.center.x = (view.center.x)
        lblCurrentScore.center.y = (view.center.y) / 2
        lblCurrentScore.alpha = 0
        lblCurrentScore.textAlignment = .center
        view.addSubview(lblCurrentScore)
        
        // Lottie confetti
        confetti.loopMode = .repeat(1)
        confetti.frame = view.bounds
        confetti.isUserInteractionEnabled = false
        
        if startOnLoad {
            startGame()
        } else {
            setStartScreen()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
