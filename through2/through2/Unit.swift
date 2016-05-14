//
//  Unit.swift
//  through2
//
//  Created by Megan on 4/8/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import Foundation

class Unit {
    var points = [NSValue]()
    var bezier = UIBezierPath()
    
    init(width: CGFloat, height: CGFloat, translation: CGPoint) {
        
        let buffer: CGFloat = width/9
        
        let x1a = CGFloat(0)
        let x1b = width/3 - buffer
        
        let x2a = width/3 + buffer
        let x2b = 2 * width/3 - buffer
        
        let x3a = 2 * width/3 + buffer
        let x3b = width
        
        let y1a = CGFloat(0)
        let y1b = height/3 - buffer
        
        let y2a = height/3 + buffer
        let y2b = 2 * height/3 - buffer
        
        let y3a = 2 * height/3 + buffer
        let y3b = height
        
        
        let p1 = randomPointInRange(x1a, hiX: x1b, loY: y3a, hiY: y3b)
        let p2 = randomPointInRange(x2a, hiX: x2b, loY: y3a, hiY: y3b)
        let p3 = randomPointInRange(x3a, hiX: x3b, loY: y3a, hiY: y3b)
        let p4 = randomPointInRange(x3a, hiX: x3b, loY: y2a, hiY: y2b)
        let p5 = randomPointInRange(x3a, hiX: x3b, loY: y1a, hiY: y1a)
        let p6 = randomPointInRange(x2a, hiX: x2b, loY: y1a, hiY: y1a)
        let p7 = randomPointInRange(x1a, hiX: x1b, loY: y1a, hiY: y1b)
        let p8 = randomPointInRange(x2a, hiX: x2b, loY: y2a, hiY: y2b)
        
        points = [NSValue(CGPoint: p1), NSValue(CGPoint: p2), NSValue(CGPoint: p3), NSValue(CGPoint: p4), NSValue(CGPoint: p5), NSValue(CGPoint: p6), NSValue(CGPoint: p7), NSValue(CGPoint: p8)]
        
        bezier = UIBezierPath.interpolateCGPointsWithCatmullRom(points, closed: true, alpha: 0.5)
        bezier.applyTransform(translationToPoint(translation.x, y: translation.y))
        calculatePoints()
    }
    
    init(startBezier: UIBezierPath, layerNumber: Int) {
        bezier = startBezier.copy() as! UIBezierPath
        bezier.applyTransform(CGAffineTransformMakeScale(1 - 0.1*CGFloat(layerNumber), 1 - 0.1*CGFloat(layerNumber)))
        bezier.applyTransform(translationToCenter(bezier, originalPath: startBezier))
        calculatePoints()
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
    
    func calculatePoints() {
        points.removeAll()
        var i = 0;
        for element in bezier {
            if (i < 8) {
                points.appendContentsOf(element.getPoints())
                i += 1
            }
        }
    }

}