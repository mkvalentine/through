//
//  Utils.swift
//  through2
//
//  Created by Megan on 5/14/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import Foundation

func randomPointInRange(loX: CGFloat, hiX: CGFloat, loY: CGFloat, hiY: CGFloat) -> CGPoint {
    let randomX = randomNumberInRange(loX, hi: hiX)
    let randomY = randomNumberInRange(loY, hi: hiY)
    return CGPointMake(randomX, randomY)
}

func randomNumberInRange(lo: CGFloat, hi : CGFloat) -> CGFloat {
    let arc4randoMax:Double = 0x100000000
    let random = (Double(arc4random()) / arc4randoMax)
    return CGFloat(random) * (hi - lo) + lo
}

func translationToCenter(path: UIBezierPath, originalPath: UIBezierPath) -> CGAffineTransform {
    let pathBounds: CGRect = path.bounds
    let originalBounds: CGRect = originalPath.bounds
    
    let translation: CGAffineTransform = CGAffineTransformMakeTranslation(-(pathBounds.origin.x - originalBounds.origin.x) - (pathBounds.size.width - originalBounds.size.width) * 0.5, -(pathBounds.origin.y - originalBounds.origin.y) - (pathBounds.size.height - originalBounds.size.height) * 0.5)
    
    return translation
}

func translationToPoint(x: CGFloat, y:CGFloat) -> CGAffineTransform {
    let translation: CGAffineTransform = CGAffineTransformMakeTranslation(x, y)
    return translation
}


