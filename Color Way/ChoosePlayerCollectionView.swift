//
//  ChoosePlayerCollectionView.swift
//  MiColorGameRoad
//
//  Created by Meshal on 4/22/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import LNZCollectionLayouts
import SwiftyUserDefaults
import UIKit

extension GameScene {
    func setCollectionView() {
        let layout = LNZCarouselCollectionViewLayout()
        // layout.animator = LinearCardAttributesAnimator(minAlpha: 0.001, itemSpacing: 0.4, scaleRate: 0.7)
        // layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: displaySize.width * 1.3, height: (displaySize.height / 6) / 1.2) // 125)
        layout.minimumScaleFactor = 0.3
        layout.isInfiniteScrollEnabled = false

        playerCollectionView.frame = CGRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height / 6)
        playerCollectionView.setCollectionViewLayout(layout, animated: true)
        playerCollectionView.center.x = (view?.center.x)!
        playerCollectionView.center.y = (view?.center.y)! + 40

        // Set up
        playerCollectionView.backgroundColor = .clear
        playerCollectionView.isPagingEnabled = false
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        playerCollectionView.reloadData()
        playerCollectionView.indicatorStyle = .default
        playerCollectionView.showsHorizontalScrollIndicator = false
        playerCollectionView.showsVerticalScrollIndicator = false
        playerCollectionView.isScrollEnabled = true
        playerCollectionView.canCancelContentTouches = false

        let indexToScrollTo = IndexPath(item: lastValidPlayerIndex, section: 0)
        playerCollectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)

        cellLabel.text = "00000000000"
        cellLabel.font = UIFont(name: "Odin-Bold", size: 16)
        cellLabel.sizeToFit()
        cellLabel.textColor = clrGray
        cellLabel.textAlignment = .center
        cellLabel.center.x = (view?.center.x)!
        cellLabel.center.y = (view?.center.y)! + 100
        view?.addSubview(cellLabel)

        btnBuy.image = UIImage(named: "coin")
        btnBuy.frame.size.width = 80
        btnBuy.center.x = (view?.center.x)!
        btnBuy.center.y = (view?.center.y)! / 1.05
        btnBuy.color = .clear
        btnBuy.alpha = 0
        btnBuy.setTitle("\(unlockPrice)", for: [])
        btnBuy.onClickAction = {
            [self] button in

            // Buying a skin
            if button.titleColor(for: []) == clrWatermelon {
                button.shake()
            } else {
                if btnBuy.title != "Buy?" {
                    btnBuy.setTitle("Buy?", for: [])
                } else {
                    purchaseSkin()
                }
            }
        }
        view?.addSubview(btnBuy)

        playerCollectionView.register(playerCell.self, forCellWithReuseIdentifier: "pCell")
        view?.bringSubviewToFront(btnBuy)
    }

    @objc func purchaseSkin() {
        if btnBuy.titleColor(for: []) == clrWatermelon {
            btnStart.shake()
            return
        }
        if let indexPath = playerCollectionView.visibleCurrentCellIndexPath {
            Defaults[\.coinsOwned] -= unlockPrice
            Defaults[\.lockedSkins]![indexPath.item] = 1
            coinsLabel.set(image: UIImage(named: "coin")!, with: "\(Defaults[\.coinsOwned])")
            coinsLabel.animation = "morph"
            coinsLabel.animateTo()
            // Confetti
            view!.addSubview(confetti)
            confetti.play { _ in self.confetti.removeFromSuperview() }

            playerCollectionView.reloadItems(at: [indexPath]) // Update cell image
            unlockCell() // Update everything else
        }
    }

    func unlockCell() {
        if let indexPath = playerCollectionView.visibleCurrentCellIndexPath {
            cellBackground.run(.fadeAlpha(to: 0.7, duration: 0.5))
            btnStart.setTitle("Play", for: [])
            btnStart.color = clrMint
            btnBuy.fadeOut(withDuration: 0.2)
            btnStart.fadeIn(withDuration: 0.2)
            btnStart.isEnabled = true
            cellParticle.particleBirthRate = 2
            cellParticle.resetSimulation()

            Defaults[\.selectedSkin] = player.skins[indexPath.item]
        }
    }
}

// MARK: - Delegates

extension GameScene: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return player.skins.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pCell", for: indexPath) as! playerCell

        if justLaunched {
            justLaunched = false
            cellLabel.text = "\(lastValidPlayerIndex + 1)/\(player.skins.count)"
            cell.pImage.image = UIImage(named: player.skins[indexPath.item])
            cellBackground.run(.fadeAlpha(to: 0.7, duration: 0.5))

            cellParticle.particleBirthRate = 2
            cellParticle.resetSimulation()
        } else {
            if Defaults[\.lockedSkins]![indexPath.item] == 1 { cell.pImage.image = UIImage(named: player.skins[indexPath.item]) }
            else { cell.pImage.image = UIImage(named: "locked") }
        }

        return cell
    }

    // Updates the playerCollectionView
    func updateCollectionView() {
        if let indexPath = playerCollectionView.visibleCurrentCellIndexPath {
            cellLabel.text = "\(indexPath.item + 1)/\(player.skins.count)"

            if Defaults[\.lockedSkins]![indexPath.item] == 1 {
                unlockCell()
            } else {
                view?.bringSubviewToFront(btnBuy)
                cellBackground.run(.fadeAlpha(to: 0.2, duration: 0.5))
                cellParticle.particleBirthRate = 0.0
                cellParticle.resetSimulation()

                btnBuy.setTitle("\(unlockPrice)", for: [])
                btnBuy.fadeIn()
                btnStart.setTitle("Buy Skin", for: [])
//                btnStart.fadeOut(withDuration: 0.2, 0.5)
//                btnStart.isEnabled = false

                if Defaults[\.coinsOwned] < unlockPrice {
                    btnBuy.setTitleColor(clrWatermelon, for: [])
                } else {
                    btnBuy.setTitleColor(.white, for: [])
                }
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCollectionView()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCollectionView()
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {}

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}

    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

extension GameScene: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 365, height: 90)
    }
}

class playerCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

//        backgroundColor = .blue
        pImage.frame.size = CGSize(width: 75, height: 75)
        pImage.center.x = frame.width / 2
        pImage.center.y = (frame.height / 2) // - 25
        pImage.transform = pImage.transform.rotated(by: 0.785398)
        pImage.tintColor = clrWatermelon
        contentView.addSubview(pImage)
//        addSubview(pName)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let pImage = UIImageView()
    var pName: UILabel {
        let label = UILabel()
        label.text = "Player"
        label.font = UIFont(name: "Odin-Bold", size: 24)
        label.sizeToFit()
        label.center.x = frame.width / 2 // self.center.x
        label.center.y = (frame.height / 2) // + (pImage.frame.height / 2.5)
        label.textColor = clrWhite
        return label
    }
}

extension UIImageView {
    /// Changes a single-color image color
    func setImageColor(color: UIColor) {
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        image = templateImage
    }
}

extension UICollectionView {
    // Get indexPath for the current visible cell
    var visibleCurrentCellIndexPath: IndexPath? {
        for cell in visibleCells {
            let indexPath = self.indexPath(for: cell)
            return indexPath
        }

        return nil
    }
}
