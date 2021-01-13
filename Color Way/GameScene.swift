//
//  GameScene.swift
//  Color Way
//
//  Created by Meshal Almutairi on 1/12/21.
//

import SpriteKit
import GameplayKit

import DynamicColor
import ChameleonFramework
import EasySocialButton
import Spring
import AnimatedCollectionViewLayout
import SwiftyUserDefaults
import TCProgressBar
import GTProgressBar
import SKTextureGradient
import LNZCollectionLayouts


var screenDiv : CGFloat = 0


//FONTS USED :: Odin Rounded ["OdinRounded-Light", "Odin-Bold", "OdinRounded"] (for reference)

let playerSkins = ["playerSkin1","playerSkin2","playerSkin3","playerSkin4","playerSkin5","playerSkin6","playerSkin7","playerSkin8","playerSkin9","playerSkin10","playerSkin11","playerSkin12","playerSkin13","playerSkin14","playerSkin15","playerSkin16","playerSkin17","playerSkin18","playerSkin19","playerSkin20"]


var selCellalpha = false


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    ///-  Variables  -///
    var player = SKSpriteNode(imageNamed: "playerSkin1")
    let playerParticle = SKEmitterNode(fileNamed: "playerParticle.sks")!
    let gradientTexture = SKTexture(size: CGSize(width: 10, height: 10), color1: CIColor(color:  .white), color2: .white)
    var playerPHY = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
    
    //weak var collectionView: playerCollectionView!
    
    ///-----=POWER UPS=----///
    
    
    var haveShield = false
    
    
    ////////----PU------///////
    let selectedCell = SKSpriteNode(imageNamed: "greenBlur")
    
    
    var playerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: UICollectionViewFlowLayout.init())
    
    var selectedTheRightCell: Int = 0
    
    let cellParticle = SKEmitterNode(fileNamed: "sparkleStar.sks")!
    
    let rightBlock = TouchableRight(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    let leftBlock = TouchableLeft(rectOf: CGSize(width: displaySize.width / 2, height: displaySize.height))
    
    let bgRadial = SKSpriteNode(imageNamed: "bgRadial")
    
    let CellsLabel = UILabel()
    
    let btnBuy = cButton(btitle: "250")
    
    
    let snowing = SKEmitterNode(fileNamed: "snowingParticle.sks")!
    let rain = SKEmitterNode(fileNamed: "rainParticle.sks")!
    let inGamesnow = SKEmitterNode(fileNamed: "inGamesnow.sks")!
        
    var BLine = SKNode()
    var coinLine = SKNode()
    
    
    let coinImage = SpringImageView(image: UIImage(named: "coin"))
    let coinsLabel = SpringLabel()
    
    
    var spot1: CGFloat = -(screenDiv * 2)
    var spot2: CGFloat = -screenDiv
    var spot3: CGFloat = 0
    var spot4: CGFloat = screenDiv
    var spot5: CGFloat = (screenDiv * 2)
    
    
    var moveRemoveAction = SKAction()
    var CoinmoveRemoveAction = SKAction()
    
    var colorsArray : [UIColor] = [.flatSkyBlue(),.flatPurple(),.flatMint(),.flatWatermelon(),.flatYellow()]
    
    var canCheck: Bool = true
    
    var logo1 = SpringImageView(image: UIImage(named: "gameLogo1"))
    var logo2 = SpringImageView(image: UIImage(named: "gameLogo2"))
    
    
    var btnStart = cButton(btitle: "Play")
    
    var score: Int = 0
    var prog: Double = 0
    
    let btnHome = cButton(btitle: "Home")
    let lblGO = SpringLabel()
    let lblGOScore = SpringLabel()
    
    let lblScore = SpringLabel()
    
    
    var gameOn: Bool = false
    var died: Bool = false
    
    
    
    var levelProg = GTProgressBar(frame: CGRect(x: 0, y: 0, width: 200, height: 30)) //GTProgressBar(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
    var levellbl = UILabel()
    
    var currentlevelBar: Int = 0
    
    var Bnum = 0
    // ~~~~~~~~.
    
    
    let loots = ["nil","coin","shield","invincible","double"]
    let lootsPercentage = [750,210,40] // SHOULD ADD UP TO 1000!
    
    ///      ---       ///
    
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        print("DID MOVE TO VIEW !!!!")
        
        self.physicsWorld.contactDelegate = self
        screenDiv = (displaySize.width / 5)
        
         spot1 = -(screenDiv * 2)
         spot2 = -screenDiv
         spot3 = 0
         spot4 = screenDiv
         spot5 = (screenDiv * 2)
        
        
        
        Defaults[\.level] = 0
        
        //if Defaults[.lockedSkins] == nil{
        Defaults[\.lockedSkins] = [1,1,1,1,0,1,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1]
        //}
        if Defaults[\.level] == 0{
            Defaults[\.level] += 1
            Defaults[\.levelBarriers] = 5
        }
        
        checkLvl()
        
        
        backgroundColor = .flatBlackDark()
        selectedTheRightCell = playerSkins.firstIndex(of: Defaults[\.selectedSkin] ?? "playerSkin1")!
        
        bgRadial.position = CGPoint(x: 0, y: 0)
        bgRadial.zPosition = -99
        bgRadial.size = displaySize.size
        bgRadial.alpha = 0.3
        addChild(bgRadial)
        
        
        //setBackground()
        setPlayer()
        
        
        ///- Replaced by Taps.v
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
        btnStart.color = .flatMint()
        view.addSubview(btnStart)
        
        
        
        
        setCollectionView()
        
        
        view.addSubview(playerCollectionView)
        
        
        
        
        coinImage.frame.size = CGSize(width: 25, height: 25)
        coinImage.center.x = displaySize.width / 1.1
        coinImage.center.y = (view.center.y) / 7
        
        
        
        coinsLabel.text = "999999999999999"
        coinsLabel.font = UIFont(name: "Odin-Bold", size: 24)
        coinsLabel.sizeToFit()
        coinsLabel.frame.size.height *= 2
        coinsLabel.textColor = .flatYellowDark()
        coinsLabel.textAlignment = .right
        coinsLabel.center.x = (displaySize.width / 1.05) - (coinsLabel.frame.size.width / 2)
        coinsLabel.center.y = (view.center.y) / 6.93
        
        coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")
        

        //view.addSubview(coinImage)
        view.addSubview(coinsLabel)
        
        
        
        

        
        selectedCell.setScale(0.5)
        selectedCell.alpha = 0.7
        selectedCell.position = CGPoint(x: 0, y: -35)
        selectedCell.zPosition = -3
        addChild(selectedCell)
        
        cellParticle.targetNode = self
        cellParticle.position.y = -23
        //cellParticle.particleColorSequence = nil
        
        
        ///- ANIMATIONS:
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
        selectedCell.isHidden = true
        
        print("GAME VIEW STARTED")
        
            self.logo1.animate()
            self.logo2.animateNext(completion: {
                
                self.selectedCell.isHidden = false
                self.playerCollectionView.fadeIn()
                self.CellsLabel.fadeIn()
                self.addChild(self.cellParticle)

                self.coinImage.animate()
                self.coinsLabel.animate()
                self.btnStart.isHidden = false
                self.btnStart.animate()
                
                
            })
        ///---------ANIMATIONS^-------////
        
        
        
        //{
        
        
        levelProg.backgroundColor = .clear
        levelProg.barFillColor = .flatSkyBlueDark()
        levelProg.barBorderColor = .clear
        levelProg.barBackgroundColor = .flatBlackDark()
        levelProg.barFillInset = 0
        levelProg.displayLabel = false
        levelProg.barBorderWidth = 0
        levelProg.cornerRadius = 15
        levelProg.progress = 0
        
        
        //levelProg.outlineColor = .clear
        //levelProg.outlineWidth = 0
        //levelProg.spacing = 0
        //levelProg.backgroundColor = .flatBlackDark
        //levelProg.progressColor = .flatMint
        levelProg.center.y = (view.center.y) / 3
        levelProg.center.x = (view.center.x)
        //levelProg.value = 0.0
        view.addSubview(levelProg)
        levelProg.alpha = 0
        
        
        levellbl.text = "level \(Defaults[\.level])"
        levellbl.font = UIFont(name: "Odin-Bold", size: 18)
        levellbl.textAlignment = .center
        levellbl.textColor = UIColor.white.withAlphaComponent(0.8)
        levellbl.sizeToFit()
        levellbl.center.y = levelProg.frame.size.height / 1.9
        levellbl.center.x = levelProg.frame.size.width / 2
        levelProg.addSubview(levellbl)
        
        
        
        view.addSubview(btnHome)
        view.addSubview(lblGO)
        view.addSubview(lblGOScore)
        btnHome.alpha = 0
        lblGO.alpha = 0
        lblGOScore.alpha = 0
        
        
        lblScore.text = "\(score)"
        lblScore.font = UIFont(name: "Odin-Bold", size: 58)
        lblScore.textColor = .flatWhite()
        lblScore.sizeToFit()
        lblScore.center.x = (view.center.x)
        lblScore.center.y = (view.center.y) / 2
        lblScore.alpha = 0
        lblScore.textAlignment = .center
        view.addSubview(lblScore)
        
        
        
        
        
    
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
