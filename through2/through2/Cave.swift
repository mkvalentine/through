//
//  Cave.swift
//  through2
//
//  Created by Megan on 4/9/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import Foundation

class Cave {
    var points = [NSValue]()
    var bezier = UIBezierPath()
    
    init(units: [Unit]) {
        let count = units.count
        if (count == 0) {
            return
        } else if (count == 1) {
            points = units[0].points
        } else {
            
            points.append(units[0].points[2])
            points.append(units[0].points[3])
            points.append(units[0].points[4])
            points.append(units[0].points[5])
            points.append(units[0].points[6])
            points.append(units[0].points[7])
            points.append(units[0].points[0])
            
            if (count-2 - 1 > 0) {
                for i in 1 ... count-2 {
                    points.append(units[i].points[4])
                    points.append(units[i].points[3])
                    points.append(units[i].points[2])
                }
            }
            
            points.append(units[count-1].points[6])
            points.append(units[count-1].points[7])
            points.append(units[count-1].points[0])
            points.append(units[count-1].points[1])
            points.append(units[count-1].points[2])
            points.append(units[count-1].points[3])
            points.append(units[count-1].points[4])
            
            if (count-2 - 1 > 0) {
                for i in 1 ... count-2 {
                    points.append(units[i].points[0])
                    points.append(units[i].points[7])
                    points.append(units[i].points[6])
                }
            }
        }
        bezier = UIBezierPath.interpolateCGPointsWithCatmullRom(points, closed: true, alpha: 0.5)
    }
}
