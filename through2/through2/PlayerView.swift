//
//  PlayerView.swift
//  through2
//
//  Created by Megan on 3/24/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import Foundation

class PlayerView: UIView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        //Base circle
        UIColor.blackColor().setFill()
        let outerPath = UIBezierPath(ovalInRect: rect)
        outerPath.fill()
    }
}
