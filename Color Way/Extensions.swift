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


/// Generates a random number in a custom range
///
/// - Parameter range: Range of the random numbers (Inclusive)
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


extension SKScene {
    
    /// Blurs the `SKScene`
    ///
    /// - Parameter radius: Blur Radius
    func addBlur(_ radius: Int = 50){
        let  blur = CIFilter(name:"CIGaussianBlur",parameters: ["inputRadius": radius])
        self.filter = blur
        self.shouldRasterize = true
        self.shouldEnableEffects = true
    }

    /// Adds snapshot animation to `SKScene`
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

extension SKSpriteNode {

    /// Adds glow effect to `SKSpriteNode`
    ///
    /// - Parameter radius: Radius of the glow
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }


    /// Changes the color of the `SKSpriteNode` to `color` with animation
    ///
    /// - Parameter color: Custom Color
    /// - Parameter dur: Cusotm Duration
    func changeColorTo(_ color : UIColor, dur : TimeInterval = 1){
        self.run(SKAction.colorize(with: color, colorBlendFactor: 1, duration: dur)) {
            self.color = color
        }
    }
    
}


// - Animating SKShapeNode color change. src: https://stackoverflow.com/a/27952397
func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat {
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
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 5
        animation.repeatCount = 999
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y - 5))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + 5))
        self.layer.add(animation, forKey: "positionY")
    }
    
    /// Fade in a view with a duration
    ///
    /// - Parameter duration: custom animation duration
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


extension UILabel {
    /// Set a UILabel with an image in addition to text
    ///
    /// - Parameter image: custom UIImage
    /// - Parameter with: custom text
    /// - Parameter RorL: Add the image to the right (`= 1`) or left (`!= 1`) of the text
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
        } else {
            mutableAttributedString.append(attachmentStr)
            mutableAttributedString.append(textString)
        }

        self.attributedText = mutableAttributedString
    }
}



