//
//  Animatable.swift
//  RevealingSplashView
//
//  Created by Chris Jimenez on 2/25/16.
//  Copyright © 2016 Chris Jimenez. All rights reserved.
//

import Foundation
import UIKit


/**
 *  Protocol that represents splash animatable functionality
 */
public protocol SplashAnimatable: AnyObject {
    
    /// The image view that shows the icon
    var imageView: UIImageView? { get set }
    
    /// The animation type
    var animationType: SplashAnimationType { get set }
    
    /// The duration of the overall animation
    var duration: Double { get set }
    
    /// The delay to play the animation
    var delay: Double { get set }
    
    /// The trigger to stop heartBeat animation
    var heartAttack: Bool { get set }
    
    /// The minimum number of beats before removing the splash view
    var minimumBeats: Int { get set }
}


/**
 The types of animation supported
 
 - Twitter: The default animation type is the Twitter App animation
 */
public enum SplashAnimationType: String{
    
    case twitter
    case rotateOut
    case woobleAndZoomOut
    case swingAndZoomOut
    case popAndZoomOut
    case squeezeAndZoomOut
    case heartBeat
    
}
