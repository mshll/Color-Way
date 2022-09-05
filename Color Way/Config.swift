//
//  Config.swift
//  Color Way
//
//  Created by Meshal Almutairi on 09/03/22.
//

import Foundation
import GameplayKit
import SpriteKit

// debug flag
let DEBUG = false

// FONTS USED :: Odin Rounded ["OdinRounded-Light", "Odin-Bold", "OdinRounded"] (for reference)

// - Main game colors
let clrSkyBlue = UIColor(hue: 0.57, saturation: 0.76, brightness: 0.86, alpha: 1)
let clrPurple = UIColor(hue: 0.70, saturation: 0.52, brightness: 0.77, alpha: 1)
let clrMint = UIColor(hue: 0.47, saturation: 0.86, brightness: 0.74, alpha: 1)
let clrWatermelon = UIColor(hue: 0.99, saturation: 0.53, brightness: 0.94, alpha: 1)
let clrYellow = UIColor(hue: 0.13, saturation: 0.99, brightness: 1.00, alpha: 1)
let clrBg = UIColor(red: 0.02, green: 0.00, blue: 0.05, alpha: 1.00)
// - Other colors used
let clrGreen = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.00)
let clrWhite = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.00)
let clrGray = UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1.00)
let clrBlack = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
let clrYellowDark = UIColor(red: 1.00, green: 0.66, blue: 0.00, alpha: 1.00)
let clrRed = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1.00)

var displaySize: CGRect = .init() // Display size
var screenDiv: CGFloat = 0 // Screen divider
var startOnLoad = false // Indicates if game should start immediately upon scene load or not
var launchDelay = 2.0 // After how many seconds should the scene get shown (waiting for splash screen animations)

let unlockPrice = 100   // Price of skins

var gameState = 0   // Flag to indicate current game state
let STARTSCREEN = 1
let INGAME = 2
let GAMEOVER = 3

let LEFT = true
let RIGHT = false
