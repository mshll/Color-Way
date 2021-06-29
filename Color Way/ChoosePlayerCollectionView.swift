//
//  ChoosePlayerCollectionView.swift
//  MiColorGameRoad
//
//  Created by Meshal on 4/22/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults
import LNZCollectionLayouts


/*class playerCollectionView: UICollectionView {
    
    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        /// set up
        backgroundColor = .clear
        isPagingEnabled = true
        self.frame = frame
        delegate = GameScene() as UICollectionViewDelegate
        dataSource = GameScene() as UICollectionViewDataSource
        reloadData()
        indicatorStyle = .default
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        isScrollEnabled = true
        canCancelContentTouches = false
        
        register(playerCell.self, forCellWithReuseIdentifier: "pCell")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}*/

extension GameScene{
    
    func setCollectionView(){
        
        
        
        let layout =  LNZCarouselCollectionViewLayout()
        //layout.animator = LinearCardAttributesAnimator(minAlpha: 0.001, itemSpacing: 0.4, scaleRate: 0.7)
        //layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:displaySize.width * 1.3 , height: (displaySize.height / 6) / 1.2 )//125)
        layout.minimumScaleFactor = 0.3
        layout.isInfiniteScrollEnabled = false
        
        
        playerCollectionView.frame = CGRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height / 6)
        playerCollectionView.setCollectionViewLayout(layout, animated: true)
        playerCollectionView.center.x = (view?.center.x)!
        playerCollectionView.center.y = (view?.center.y)! + 40
        
        // Set up
        playerCollectionView.backgroundColor = .clear
        //playerCollectionView.isPagingEnabled = true
        //self.frame = frame
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        playerCollectionView.reloadData()
        playerCollectionView.indicatorStyle = .default
        playerCollectionView.showsHorizontalScrollIndicator = false
        playerCollectionView.showsVerticalScrollIndicator = false
        
        playerCollectionView.isScrollEnabled = true
        playerCollectionView.canCancelContentTouches = false
        
        
        
        let indexToScrollTo = IndexPath(item: lastValidPlayerIndex, section: 0)
        self.playerCollectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)
        
        
        
        
        cellLabel.text = "1/200000000"
        cellLabel.font = UIFont(name: "Odin-Bold", size: 16)
        cellLabel.sizeToFit()
        cellLabel.textColor = clrGray
        cellLabel.textAlignment = .center
        cellLabel.center.x = (view?.center.x)!
        cellLabel.center.y = (view?.center.y)! + 100
        view?.addSubview(cellLabel)
        
        
        btnBuy.image = UIImage(named: "coin")
        btnBuy.frame.size.width = 100
        btnBuy.center.x = (view?.center.x)!
        btnBuy.center.y = (view?.center.y)! / 1.05
        btnBuy.color = .clear
        btnBuy.alpha = 0
        view?.addSubview(btnBuy)
        view?.bringSubviewToFront(btnBuy)
        
        playerCollectionView.register(playerCell.self, forCellWithReuseIdentifier: "pCell")
    }
    
}

// MARK: - Delegates
extension GameScene: UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return player.skins.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //.......
        cellLabel.text = "\(indexPath.item + 1)/\(player.skins.count)"
        
        func unlockCell() {
            cell.pImage.image = UIImage(named: player.skins[indexPath.item])
            cellBackground.alpha = 0.7
            
            btnBuy.fadeOut(withDuration: 0.2)
            btnStart.fadeIn(withDuration: 0.2)
            btnStart.isEnabled = true
            
            cellParticle.particleBirthRate = 2
            cellParticle.resetSimulation()

            Defaults[\.selectedSkin] = player.skins[indexPath.item]
        }
        
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "pCell", for: indexPath) as! playerCell
        
        //modify cell subviews.
        var confirmBuy = false
        btnBuy.setTitle("250", for: [])
        
        btnBuy.onClickAction = { [self]
            (button) in
            
            // Buying a skin
            if button.titleColor(for: []) == clrWatermelon {
                print("not enough money.")
                button.shake()
                
            } else{
                
                if !confirmBuy{
                    btnBuy.setTitle("Buy?", for: [])
                    confirmBuy = true
                } else {
                    Defaults[\.coinsOwned] -= 250
                    Defaults[\.lockedSkins]![indexPath.item] = 1
                    coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")
                    coinsLabel.animation = "morph"
                    coinsLabel.animateTo()
                    
                    // Confetti
                    view!.addSubview(confetti)
                    confetti.play { _ in confetti.removeFromSuperview() }
                    
                    unlockCell()
                }
                
            }
        }
        view?.bringSubviewToFront(btnBuy)
        
        if Defaults[\.lockedSkins]![indexPath.item] == 1{
            unlockCell()
            
        } else {
            
            cell.pImage.image = UIImage(named: "locked")
            cellBackground.alpha = 0.2
            
            btnBuy.fadeIn()
            btnBuy.alpha = 1
            
            btnStart.fadeOut(withDuration: 0.2, 0.5)
            btnStart.isEnabled = false
            
            cellParticle.particleBirthRate = 0.0
            cellParticle.resetSimulation()

            
            if Defaults[\.coinsOwned] < 250{
                btnBuy.setTitleColor(clrWatermelon, for: [])
            } else {
                btnBuy.setTitleColor(.white, for: [])
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //CELL TOUCH:
    }
    
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    
    
}

extension GameScene: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 365, height: 90)
    }
    
    
}




class playerCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let pImage = UIImageView()
    var pName: UILabel{
        let label = UILabel()
        label.text = "Player"
        label.font = UIFont(name: "Odin-Bold", size: 24)
        label.sizeToFit()
        label.center.x = self.frame.width / 2//self.center.x
        label.center.y = (self.frame.height / 2)// + (pImage.frame.height / 2.5)
        label.textColor = clrWhite
        return label
    }
    
    
    func setupView(){
        //backgroundColor = .blue
        
        
        
        pImage.frame.size = CGSize(width: 75, height: 75)
        pImage.center.x = self.frame.width / 2
        pImage.center.y = (self.frame.height / 2) //- 25
        pImage.transform = pImage.transform.rotated(by: 0.785398)
        pImage.tintColor = clrWatermelon
        contentView.addSubview(pImage)
        //contentView.addSubview(pImage)
        //addSubview(pName)
        
    }
    
}


extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        
    }
}



