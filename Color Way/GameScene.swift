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
let clrBlackDark = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
let clrYellowDark = UIColor(red: 1.00, green: 0.66, blue: 0.00, alpha: 1.00)


var screenDiv : CGFloat = 0
var playerSkins: [String] = []


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // -  Variables  - //
    var player = SKSpriteNode(imageNamed: "playerSkin1")
    let playerParticle = SKEmitterNode(fileNamed: "playerParticle.sks")!
    //let gradientTexture = SKTexture(size: CGSize(width: 10, height: 10), color1: CIColor(color:  .white), color2: .white)
    var playerPHY = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
        
    
    // ----= POWER UPS =---- //
    var haveShield = false
    
    
    // --- Set up player selection view ---
    let cellBackground = SKSpriteNode(imageNamed: "greenBlur")    // Skin cell background
    
    var playerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: UICollectionViewFlowLayout.init())
    
    var correctPlayerCellIndex: Int = 0
    let cellParticle = SKEmitterNode(fileNamed: "sparkleStar.sks")!
    
    let rightBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    let leftBlock = TouchableNode(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    
    let bgRadial = SKSpriteNode(imageNamed: "bgRadial")
    let CellsLabel = UILabel()
    
    let btnBuy = cButton(btitle: "250")
    
    // Particles:
    let snowing = SKEmitterNode(fileNamed: "snowingParticle.sks")!
    let rain = SKEmitterNode(fileNamed: "rainParticle.sks")!
    let inGamesnow = SKEmitterNode(fileNamed: "inGamesnow.sks")!
        
    
    var barriersLine = SKNode()
    var coinLine = SKNode()
    
    
    let coinImage = SpringImageView(image: UIImage(named: "coin"))
    let coinsLabel = SpringLabel()
    
    
    // Dividing the screen to 5 parts
    var screenSpots: [CGFloat] = [-(screenDiv * 2), -screenDiv, 0, screenDiv, (screenDiv * 2)]
    
    
    // Gameplay actions (moving barriers and coins/powerups)
    var moveRemoveAction = SKAction()
    var CoinmoveRemoveAction = SKAction()
    
    // Barriers colors
    var colorsArray : [UIColor] = [clrSkyBlue, clrPurple, clrMint, clrWatermelon, clrYellow]
    
    var canCheck: Bool = true
    
    var logo1 = SpringImageView(image: UIImage(named: "gameLogo1"))
    var logo2 = SpringImageView(image: UIImage(named: "gameLogo2"))
    
    
    var btnStart = cButton(btitle: "Play")
    
    var score: Int = 0
    
    let btnHome = cButton(btitle: "Home")
    let lblGO = SpringLabel()
    let lblGOScore = SpringLabel()
    let lblGOHiScore = SpringLabel()
    
    let lblCurrentScore = SpringLabel()
    
    
    var gameOn: Bool = false
    var playerDead: Bool = false
    
    
    
    var currentlevelBar: Int = 0
    var barrierNum = 0
    // ~~~~~~~~.
    
    
    let loots = ["nil","coin","shield","invincible","double"]
    let lootsPercentage = [750,210,40] // SHOULD ADD UP TO 1000!
    
    ///      ---       ///
    
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        print("DID MOVE TO VIEW !!!!")
        
        // Set player skins names
        for i in 1...20 {
            playerSkins.append("playerSkin\(i)")
        }
        
        self.physicsWorld.contactDelegate = self
        screenDiv = (displaySize.width / 5)
        
        screenSpots = [-(screenDiv * 2), -screenDiv, 0, screenDiv, (screenDiv * 2)]
        
        
        if Defaults[\.lockedSkins] == nil {
        Defaults[\.lockedSkins] = [1,1,1,1,0,1,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1]
        }
        
        backgroundColor = clrBlackDark
        correctPlayerCellIndex = playerSkins.firstIndex(of: Defaults[\.selectedSkin] ?? "playerSkin1")!
        
        bgRadial.position = CGPoint(x: 0, y: 0)
        bgRadial.zPosition = -99
        bgRadial.size = displaySize.size
        bgRadial.alpha = 0.3
        addChild(bgRadial)
        
        setPlayer()
        
        
        //- Replaced by Taps
        //addSwipes()
        
        snowing.targetNode = self
        snowing.position.y = displaySize.height / 2
        addChild(snowing)
        
        logo1.frame.size = CGSize(width: logo1.frame.size.width * 0.7,
                                  height: logo1.frame.size.height * 0.7)
        logo1.center.x = view.center.x
        logo1.center.y = displaySize.height / 5
        
        logo2.frame.size = CGSize(width: logo2.frame.size.width * 0.7,
                                  height: logo2.frame.size.height * 0.7)
        logo2.center.x = view.center.x
        logo2.center.y = displaySize.height / 5
        
        
        
        
        view.addSubview(self.logo1)
        view.addSubview(self.logo2)
        
        
        
        btnStart.center.x = view.center.x
        btnStart.center.y = view.center.y * 1.5
        btnStart.onClickAction = {
            (button) in
            self.startGame()
        }
        btnStart.color = clrMint
        view.addSubview(btnStart)
        
        setCollectionView()
        view.addSubview(playerCollectionView)
        
        
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
        
        
        cellBackground.setScale(0.5)
        cellBackground.alpha = 0.7
        cellBackground.position = CGPoint(x: 0, y: -35)
        cellBackground.zPosition = -3
        addChild(cellBackground)
        
        cellParticle.targetNode = self
        cellParticle.position.y = -23
        //cellParticle.particleColorSequence = nil
        
        
        //- ANIMATIONS:
        logo1.animation = "squeezeRight"
        logo2.animation = "squeezeLeft"
        
        logo1.delay = 0.2
        logo2.delay = 0.7
        
        btnStart.animation = "zoomIn"
        coinImage.animation = "squeezeLeft"
        coinsLabel.animation = "squeezeLeft"
        
        
        btnStart.isHidden = true
        coinImage.alpha = 0
        coinsLabel.alpha = 0
        CellsLabel.alpha = 0
        playerCollectionView.alpha = 0
        cellBackground.isHidden = true
        
        print("GAME VIEW STARTED")
        
            self.logo1.animate()
            self.logo2.animateNext(completion: {
                
                self.cellBackground.isHidden = false
                self.playerCollectionView.fadeIn()
                self.CellsLabel.fadeIn()
                self.addChild(self.cellParticle)

                self.coinImage.animate()
                self.coinsLabel.animate()
                self.btnStart.isHidden = false
                self.btnStart.animate()
                
                
            })
        // ---------^END OF ANIMATIONS^------- //
        
        
                    
        
        view.addSubview(btnHome)
        view.addSubview(lblGO)
        view.addSubview(lblGOScore)
        view.addSubview(lblGOHiScore)
        btnHome.alpha = 0
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        lblGOHiScore.alpha = 0
        
        
        lblCurrentScore.text = "\(score)"
        lblCurrentScore.font = UIFont(name: "Odin-Bold", size: 58)
        lblCurrentScore.textColor = clrWhite
        lblCurrentScore.sizeToFit()
        lblCurrentScore.center.x = (view.center.x)
        lblCurrentScore.center.y = (view.center.y) / 2
        lblCurrentScore.alpha = 0
        lblCurrentScore.textAlignment = .center
        view.addSubview(lblCurrentScore)
    
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
