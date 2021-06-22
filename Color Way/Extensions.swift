//
//  extensions+functions (dl).swift
//  Color Way
//
//  Created by Meshal on 4/17/18.
//  Copyright © 2018 Meshal. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import CoreImage

extension SKScene {
    func addBlur(_ radius: Int = 50){
        let  blur = CIFilter(name:"CIGaussianBlur",parameters: ["inputRadius": radius])
        self.filter = blur
        self.shouldRasterize = true
        self.shouldEnableEffects = true



    }

    func showScreenshotEffect() {

        let snapshotView = UIView()
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(snapshotView)

        let constraints:[NSLayoutConstraint] = [
            snapshotView.topAnchor.constraint(equalTo: (view?.topAnchor)!),
            snapshotView.leadingAnchor.constraint(equalTo: (view?.leadingAnchor)!),
            snapshotView.trailingAnchor.constraint(equalTo: (view?.trailingAnchor)!),
            snapshotView.bottomAnchor.constraint(equalTo: (view?.bottomAnchor)!)
        ]
        NSLayoutConstraint.activate(constraints)

        snapshotView.backgroundColor = UIColor.white

        UIView.animate(withDuration: 0.2, animations: {
            snapshotView.alpha = 0
        }) { _ in
            snapshotView.removeFromSuperview()
        }
    }
}

extension SKScene{

    func snap(){


        if let wnd = self.view{

            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = .white
            v.alpha = 1

            wnd.addSubview(v)
            UIView.animate(withDuration: 1, animations: {
                v.alpha = 0.0
            }, completion: {(finished:Bool) in
                print("inside")
                v.removeFromSuperview()
            })
        }


    }

}
extension SKSpriteNode {

    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }


}


extension SKSpriteNode {
    //
    func changeColorTo(_ color : UIColor, dur : TimeInterval){
        self.run(SKAction.colorize(with: color, colorBlendFactor: 1, duration: dur)) {
            self.color = color
        }
    }
}


// - Animating SKShapeNode color change. src: https://stackoverflow.com/a/27952397
func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
{
    return (b-a) * fraction + a
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}

extension UIColor {
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
}

extension SKAction {
    static func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 0.4) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = UIColor(red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            (node as? SKShapeNode)?.fillColor = transColor
        }
        )
    }
}
// - End of Animating SKShapeNode color change


func newExpo(_ color: UIColor) -> SKEmitterNode {
    let emNode = SKEmitterNode(fileNamed: "explosionParticle")!
    emNode.particleColor = color
  return emNode
}

func newExplosion(_ color: UIColor) -> SKEmitterNode {

    let explosion = SKEmitterNode()

    let image = UIImage(named:"sq.png")!
    explosion.particleTexture = SKTexture(image: image)
    explosion.particleColor = color
    explosion.numParticlesToEmit = 50
    explosion.particleBirthRate = 100
    explosion.particleLifetime = 3
    explosion.emissionAngleRange = 360
    explosion.particleSpeed = 200
    explosion.particleSpeedRange = 50
    explosion.xAcceleration = 0
    explosion.yAcceleration = 0
    explosion.particleAlpha = 1
    explosion.particleAlphaRange = 0
    explosion.particleAlphaSpeed = 0
    explosion.particleScale = 0.3
    explosion.particleScaleRange = 0//0.75
    explosion.particleScaleSpeed = -0.5
    explosion.particleRotation = 180
    explosion.particleRotationRange = 90
    explosion.particleRotationSpeed = -0.5
    explosion.particleColorBlendFactor = 1
    explosion.particleColorBlendFactorRange = 0
    explosion.particleColorBlendFactorSpeed = 0
    explosion.particleBlendMode = SKBlendMode.alpha

    return explosion
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


func delayCode(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

extension UIView {
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }

    func float(){

        let animationx = CABasicAnimation(keyPath: "position")
        animationx.duration = 5
        animationx.repeatCount = 999
        animationx.autoreverses = true
        animationx.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y - 5))
        animationx.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + 5))
        self.layer.add(animationx, forKey: "positionY")




    }
}

extension SKNode{

    func shake(){

        let anim = SKAction.sequence([
            .moveBy(x: 10, y: 0, duration: 0.07),
            .moveBy(x: -10, y: 0, duration: 0.07),
            .moveBy(x: 10, y: 0, duration: 0.07),
            .moveBy(x: -10, y: 0, duration: 0.07),
            .moveBy(x: 10, y: 0, duration: 0.07),
            .moveBy(x: -10, y: 0, duration: 0.07)
            ])
        self.run(anim)

    }
}
extension SKScene{


    func SnapshotAnim(){
        let white = SKShapeNode(rectOf: (self.view?.frame.size)!)
        white.fillColor = clrWhite
        white.zPosition = 999

        self.addChild(white)
        white.alpha = 0

        white.run(.sequence([
            .fadeIn(withDuration: 0.15),
            .fadeOut(withDuration: 0.15)
            ])) {
                white.removeFromParent()
        }
    }


}

extension UIView{

    /// Fade in a view with a duration
    ///
    /// Parameter duration: custom animation duration
    func fadeIn(withDuration duration: TimeInterval = 0.5,_ alpha: CGFloat = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }

    /// Fade out a view with a duration
    ///
    /// - Parameter duration: custom animation duration
    func fadeOut(withDuration duration: TimeInterval = 0.5,_ alpha: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
}


public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...100) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}


extension Collection {
    func randomItem() -> Self.Iterator.Element {
        let count = distance(from: startIndex, to: endIndex)
        let roll = randomNumber(inRange: 0...count-1)
        return self[index(startIndex, offsetBy: roll)]
    }
}


extension UILabel {
    func set(image: UIImage, with text: String, RorL: Int = 1) {
        let attachment = NSTextAttachment()
        attachment.image = image


        attachment.bounds = CGRect(x: 0, y: -3, width: self.frame.height / 2, height: self.frame.height / 2)

        let attachmentStr = NSAttributedString(attachment: attachment)

        let mutableAttributedString = NSMutableAttributedString()

        let textString = NSAttributedString(string: " \(text) ", attributes: [.font: self.font!])


        if RorL == 1{
            mutableAttributedString.append(textString)
            mutableAttributedString.append(attachmentStr)
        } else{
            mutableAttributedString.append(attachmentStr)
            mutableAttributedString.append(textString)
        }


        self.attributedText = mutableAttributedString
    }
}



