//
//  Colors.swift
//  through2
//
//  Created by Megan on 4/12/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import Foundation

var colorPalette = 0

enum Layers: Int {
    case zero = 0
    case one
    case two
    case three
    case four
    case five
    
    var color: UIColor {
        switch self {
        case .zero:
            if (colorPalette == 0) {
                return UIColor(hue: 0.0167, saturation: 0.01, brightness: 0.99, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.0167, saturation: 0.01, brightness: 0.99, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.025, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.5806, saturation: 0.88, brightness: 0.42, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0.9694, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
            } else {
                return UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
            }
        case .one:
            if (colorPalette == 0) {
                return UIColor(hue: 0.7889, saturation: 0.06, brightness: 0.91, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.5861, saturation: 0.58, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.5861, saturation: 0.58, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.4889, saturation: 0.64, brightness: 0.4, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0.5889, saturation: 0.1, brightness: 1, alpha: 1.0)
            } else {
                return UIColor(hue: 0.5333, saturation: 0.82, brightness: 0.33, alpha: 1.0)
            }
        case .two:
            if (colorPalette == 0) {
                return UIColor(hue: 0.1778, saturation: 0.47, brightness: 0.85, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.5889, saturation: 0.34, brightness: 0.98, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.0167, saturation: 1, brightness: 0.78, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.4444, saturation: 0.66, brightness: 0.52, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0.1444, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0.9806, saturation: 0.64, brightness: 1, alpha: 1.0)
            } else {
                return UIColor(hue: 0.5306, saturation: 0.72, brightness: 0.63, alpha: 1.0)
            }
        case .three:
            if (colorPalette == 0) {
                return UIColor(hue: 0.4667, saturation: 0.48, brightness: 0.8, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.4583, saturation: 0.02, brightness: 0.68, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.0194, saturation: 1, brightness: 0.66, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.1889, saturation: 0.76, brightness: 0.61, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0.1528, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0.9694, saturation: 1, brightness: 1, alpha: 1.0)
            } else {
                return UIColor(hue: 0.5361, saturation: 0.81, brightness: 1, alpha: 1.0)
            }
        case .four:
            if (colorPalette == 0) {
                return UIColor(hue: 0.5694, saturation: 0.76, brightness: 0.74, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.6667, saturation: 0, brightness: 0.93, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.0167, saturation: 1, brightness: 0.78, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.1861, saturation: 1, brightness: 0.82, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0.1583, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0.6583, saturation: 0.84, brightness: 0.54, alpha: 1.0)
            } else {
                return UIColor(hue: 0.5333, saturation: 0.71, brightness: 0.74, alpha: 1.0)
            }
        case .five:
            if (colorPalette == 0) {
                return UIColor(hue: 0.8417, saturation: 0.63, brightness: 0.27, alpha: 1.0)
            } else if (colorPalette == 1) {
                return UIColor(hue: 0.1417, saturation: 0.76, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 2) {
                return UIColor(hue: 0.025, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 3) {
                return UIColor(hue: 0.1444, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 4) {
                return UIColor(hue: 0.1667, saturation: 1, brightness: 1, alpha: 1.0)
            } else if (colorPalette == 5) {
                return UIColor(hue: 0.7472, saturation: 1, brightness: 0.28, alpha: 1.0)
            } else {
                return UIColor(hue: 0.5306, saturation: 0.72, brightness: 0.63, alpha: 1.0)
            }
        }
    }
}
