//
//  GameScene.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import SpriteKit
import GameplayKit
import Spring
import SwiftyUserDefaults
import LNZCollectionLayouts
import Lottie


//FONTS USED :: Odin Rounded ["OdinRounded-Light", "Odin-Bold", "OdinRounded"] (for reference)


// - Main game colors
let clrSkyBlue = UIColor(hue: 0.57, saturation: 0.76, brightness: 0.86, alpha: 1)
let clrPurple = UIColor(hue: 0.70, saturation: 0.52, brightness: 0.77, alpha: 1)
let clrMint = UIColor(hue: 0.47, saturation: 0.86, brightness: 0.74, alpha: 1)
let clrWatermelon = UIColor(hue: 0.99, saturation: 0.53, brightness: 0.94, alpha: 1)
let clrYellow = UIColor(hue: 0.13, saturation: 0.99, brightness: 1.00, alpha: 1)

// - Other colors used
let clrGreen = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.00)
let clrWhite = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.00)
let clrGray = UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1.00)
let clrBlack = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
let clrBlackDark = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.00)
let clrYellowDark = UIColor(red: 1.00, green: 0.66, blue: 0.00, alpha: 1.00)
let clrRed = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1.00)


var screenDiv : CGFloat = 0 // Screen divider
var playAgain: Bool = false // Indicates if game should start immediately upon scene load or not
var launchDelay = 2.0       // After how many seconds should the scene get shown (waiting for splash screen animations)


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Player structure
    struct Player {
        var node = SKSpriteNode(imageNamed: "playerSkin1")
        let particle = SKEmitterNode(fileNamed: "playerParticle.sks")!
        var phyNode = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
        var skins = Array(repeating: "", count: 20)
        var isDead = false
        var pos = 3
        var shield = false
        var god = false
    }
    
    
    // MARK: Variables  //
    
    var player = Player()   // initalize player
    var spawnDur: CGFloat = 2.0 // Interval between each barrier/loot spawn
    let bgRadial = SKSpriteNode(imageNamed: "bgRadial") // Radial background for in-game

    // Set up player selection view
    let cellBackground = SKSpriteNode(imageNamed: "greenBlur")    // Skin cell background
    var playerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: UICollectionViewFlowLayout.init())
    var lastValidPlayerIndex: Int = 0
    let cellParticle = SKEmitterNode(fileNamed: "sparkleStar.sks")!
    let cellLabel = UILabel()  // Label that shows which cell you're on
    let btnBuy = cButton(btitle: "250")
    
    // Taps
    let rightBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    let leftBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    
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
    var screenSpots: [CGFloat] = [-(screenDiv * 2), -screenDiv, 0, screenDiv, (screenDiv * 2)]
    
    // Barriers colors
    var colorsArray : [UIColor] = [clrSkyBlue, clrPurple, clrMint, clrWatermelon, clrYellow]
    
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
    let loots = ["nil", "coin", "shield", "skull", "double"]    // 'double' unused
    let lootWeight = [70, 20, 5, 5, 0]  // Weight for loot [i] to be chosen -: SHOULD ADD UP TO 100!
    let lootMax = [5, 3, 2, 2, 0]       // Max # of loot [i] in a line (Max # = 5)

    let confetti = AnimationView(name: "conf")
    //  ***  End of Variables  ***  //
    
    
    // MARK: didMove to view
    override func didMove(to view: SKView) {
        
        // Set player skins names
        for i in 0...(player.skins.count-1) {
            player.skins[i] = ("playerSkin\(i+1)")
        }
        
        self.physicsWorld.contactDelegate = self
        screenDiv = (displaySize.width / 5) // Set screen divider
        
        // Divides screen to 5 spaces
        screenSpots = [-(screenDiv * 2), -screenDiv, 0, screenDiv, (screenDiv * 2)]
        
        
        // Initialize skins
        if Defaults[\.lockedSkins] == nil {
            Defaults[\.lockedSkins] = Array(repeating: 0, count: 20)
            Defaults[\.lockedSkins]![0] = 1 // Unlock first skin
        }
        
        backgroundColor = clrBlackDark
        lastValidPlayerIndex = player.skins.firstIndex(of: Defaults[\.selectedSkin] ?? "playerSkin1")! // Set which index should be selected for the selection view
        
        // Setup the radial background
        bgRadial.position = CGPoint(x: 0, y: 0)
        bgRadial.zPosition = -99
        bgRadial.size = displaySize.size
        bgRadial.alpha = 0.3
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
        
        
        if playAgain {
            startGame()
        } else {
            setStartScreen()
        }
        
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
