//
//  ViewController.swift
//  through2
//
//  Created by Megan on 2/24/16.
//  Copyright © 2016 Megan. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import Foundation

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollisionBehaviorDelegate {
    
    // For controlling page turn and scroll
    var pageController: UIPageViewController!
    var controllers = [UIViewController]()
    var scrollViews = [UIScrollView]()
    
    // Keep track of player
    var player: UIView?
    var playerPosition = CGPoint(x: 0, y: 0)
    var playerDefaultJumpPoint = CGPoint(x: 0, y: 0)
    
    // For drawing caves
    var caves = [UIBezierPath]()
    
    var units = [[Unit?]]()
    
    var cavesLayerZero = [Cave]()
    var cavesLayerOne = [Cave]()
    var cavesLayerTwo = [Cave]()
    var cavesLayerThree = [Cave]()
    var cavesLayerFour = [Cave]()
    
    var shapeLayers = [[CAShapeLayer]]()
    var maskLayers = [CAShapeLayer]()
    
    // Audio Variables
    var music = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Through_ingame_music_2", ofType: "mp3")!)
    var pageSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("page_1", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    var audioPlayerPage = AVAudioPlayer()
    
    // Keep track of whether animations are currently occuring
    var pageIsAnimating: Bool = false
    var caveIsAnimating: Bool = false
    
    // Keep track of location of marble in maze
    var swipeRight: Bool = false
    var index: Int = 0
    
    // Depth and length of maze
    let nLayers: Int = 6
    let nUnits: Int = 28
    
    // For getting device motion updates
    let motionQueue = NSOperationQueue()
    let motionManager = CMMotionManager()
    
    // For physics
    var animators = [UIDynamicAnimator?]()
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    let elasticity = UIDynamicItemBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collider.collisionDelegate = self
        
        pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        
        let views = ["pageController": pageController.view] as [String: AnyObject]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageController]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageController]|", options: [], metrics: nil, views: views))
        
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        shapeLayers = Array(count: 6, repeatedValue: [CAShapeLayer]())
        
        let buffer = self.view.bounds.maxY/4
        
        makeUnits(self.view.bounds.maxX, height: self.view.bounds.maxY, buffer: buffer)
        makeCavesFromUnits()
        
        for i in 1 ... 5 {
            let vc = UIViewController()
            
            let scrollView = UIScrollView(frame: vc.view.bounds)
            scrollView.contentSize = CGRect(x: 0, y: 0, width: vc.view.bounds.width*5, height: CGFloat(nUnits/2) * self.view.bounds.maxY + CGFloat(nUnits/2) * buffer + 2 * self.view.bounds.maxY).size
            scrollView.scrollEnabled = false
            
            vc.view = scrollView
            scrollViews.append(scrollView)
            
            drawCavesForMaze(vc, layerNumber: i, height: self.view.bounds.maxY, buffer: buffer)
            
            controllers.append(vc)
            
            let animator = UIDynamicAnimator(referenceView: controllers[i-1].view)
            animators.append(animator)
        }
        
        pageController.setViewControllers([controllers[0]], direction: .Forward, animated: false, completion: nil)
        
        buildMasks()
        addPlayerToInitialView(0)
        addAnimationToView(0)
        
        playMusic()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "gravityUpdated", userInfo: nil, repeats: true)
        
        motionManager.deviceMotionUpdateInterval =  1.0 / 60.0
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical)
    }
    
    override func viewWillDisappear(animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func gravityUpdated() {
        if (shoudAnimate()) {
            animateCaves()
        }
        
        if let deviceMotion = self.motionManager.deviceMotion {
            let attitude: CMAttitude = deviceMotion.attitude
            gravity.gravityDirection = CGVectorMake(CGFloat(attitude.roll) * 0.8, CGFloat(attitude.pitch) * 0.8)
        }
        else {
            return
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageIsAnimating = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if (pageIsAnimating) {
            return nil
        }
        if let index = controllers.indexOf(viewController) {
            let currentPosition = CGPointMake(player!.frame.minX, player!.frame.minY)
            if (index > 0 && shouldTurnPage(currentPosition, viewNumber: index-1)) {
                addMask(controllers[index-1], layerNumber: index-1)
                playPageSound()
                swipeRight = false
                return controllers[index - 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if (pageIsAnimating) {
            return nil
        }
        if let index = controllers.indexOf(viewController) {
            let currentPosition = CGPointMake(player!.frame.minX, player!.frame.minY)
            if (index < controllers.count - 1 && shouldTurnPage(currentPosition, viewNumber: index+1)) {
                addMask(controllers[index], layerNumber: index)
                playPageSound()
                swipeRight = true
                return controllers[index + 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed || finished) {
            pageIsAnimating = false
        }
        removeMask(controllers[index], layerNumber: index)
        if (completed) {
            
            let currentPosition = CGPointMake(player!.frame.minX, player!.frame.minY)
            
            removeAnimationFromView(index)
            removePlayerFromAllViews()
            
            if (swipeRight) {
                index += 1
                addPlayerToView(currentPosition, viewNumber: index)
                addAnimationToView(index)
            } else {
                index -= 1
                removeMask(controllers[index], layerNumber: index)
                addPlayerToView(currentPosition, viewNumber: index)
                addAnimationToView(index)
            }
        }
        return
    }
    
    func addPlayerToInitialView(viewNumber: Int) {
        let r: CGFloat = 30.0
        
        let xLo = cavesLayerZero[0].bezier.bounds.minX
        let xHi = cavesLayerZero[0].bezier.bounds.maxX
        let yLo = cavesLayerZero[0].bezier.bounds.minY
        let yHi = cavesLayerZero[0].bezier.bounds.maxY
        
        var point = CGPoint()
        
        repeat {
            point = randomPointInRange(xLo, hiX: xHi, loY: yLo, hiY: yHi)
        } while (!isFullyInside(point, viewNumber: viewNumber))
        
        let newPlayer = PlayerView(frame: CGRectMake(point.x, point.y, r, r))
        newPlayer.backgroundColor = UIColor.clearColor()
        controllers[viewNumber].view.insertSubview(newPlayer, atIndex: 10)
        player = newPlayer
    }
    
    func addPlayerToView(currentPoint: CGPoint, viewNumber: Int) {
        let r: CGFloat = 30.0
        
        let point = newPosition(currentPoint, viewNumber: viewNumber)
        
        let newPlayer = PlayerView(frame: CGRectMake(point.x, point.y, r, r))
        newPlayer.backgroundColor = UIColor.clearColor()
        
        controllers[viewNumber].view.insertSubview(newPlayer, atIndex: 10)
        player = newPlayer
    }
    
    func removePlayerFromAllViews() {
        for i in 0 ... controllers.count-1 {
            for subview in controllers[i].view.subviews {
                subview.removeFromSuperview()
            }
        }
        player = nil
    }
    
    func jumpPoint(currentPoint: CGPoint, magnitude: CGFloat, angleChange: CGFloat) -> CGPoint {
        let theta = gravity.angle + CGFloat(M_PI) + angleChange
        let newX = currentPoint.x + magnitude * cos(theta)
        let newY = currentPoint.y + magnitude * sin(theta)
        return CGPoint(x: newX, y: newY)
    }
    
    func shouldTurnPage(currentPoint: CGPoint, viewNumber: Int) -> Bool {
        if (isFullyInside(currentPoint, viewNumber: viewNumber)) {
            playerDefaultJumpPoint = currentPoint
            return true
        }
        
        var point = CGPoint()
        
        let fromAngle = CGFloat(0.0)
        let toAngle = CGFloat(M_PI)
        let stepAngle = CGFloat(M_PI)/16
        let angleSequence = fromAngle.stride(to: toAngle, by: stepAngle)
        
        
        let fromHeight = CGFloat(10.0)
        let toHeight = CGFloat(200.0)
        let stepHeight = CGFloat(10.0)
        let heightSequence = fromHeight.stride(to: toHeight, by: stepHeight)
        
        for theta in angleSequence {
            for height in heightSequence {
                point = jumpPoint(currentPoint, magnitude: height, angleChange: theta)
                if (isFullyInside(point, viewNumber: viewNumber)) {
                    playerDefaultJumpPoint = point
                    return true
                }
                point = jumpPoint(currentPoint, magnitude: height, angleChange: -theta)
                if (isFullyInside(point, viewNumber: viewNumber)) {
                    playerDefaultJumpPoint = point
                    return true
                }
            }
        }
        
        playerDefaultJumpPoint = CGPoint(x: 0, y: 0)
        return false
    }
    
    func newPosition(currentPoint: CGPoint, viewNumber: Int) -> CGPoint {
        
        if (isFullyInside(currentPoint, viewNumber: viewNumber)) {
            return currentPoint
        }
        
        var point = CGPoint()
        
        let fromAngle = CGFloat(0.0)
        let toAngle = CGFloat(M_PI)
        let stepAngle = CGFloat(M_PI)/16
        let angleSequence = fromAngle.stride(to: toAngle, by: stepAngle)
        
        
        let fromHeight = CGFloat(10.0)
        let toHeight = CGFloat(200.0)
        let stepHeight = CGFloat(10.0)
        let heightSequence = fromHeight.stride(to: toHeight, by: stepHeight)
        
        for theta in angleSequence {
            for height in heightSequence {
                point = jumpPoint(currentPoint, magnitude: height, angleChange: theta)
                if (isFullyInside(point, viewNumber: viewNumber)) {
                    return point
                }
                point = jumpPoint(currentPoint, magnitude: height, angleChange: -theta)
                if (isFullyInside(point, viewNumber: viewNumber)) {
                    return point
                }
            }
        }
        
        return playerDefaultJumpPoint
    }
    
    func isFullyInside(point: CGPoint, viewNumber: Int) -> Bool {
        let xLeft = point.x - 40
        let xRight = point.x + 40
        let yBottom = point.y - 40
        let yTop = point.y + 40
        
        let point1 = CGPoint(x: xLeft, y: yBottom)
        let point2 = CGPoint(x: xLeft, y: yTop)
        let point3 = CGPoint(x: xRight, y: yBottom)
        let point4 = CGPoint(x: xRight, y: yTop)
        
        switch viewNumber {
        case 0:
            for cave in cavesLayerZero {
                if (cave.bezier.containsPoint(point1) && cave.bezier.containsPoint(point2) && cave.bezier.containsPoint(point3) && cave.bezier.containsPoint(point4)) {
                    return true
                }
            }
        case 1:
            for cave in cavesLayerOne {
                if (cave.bezier.containsPoint(point1) && cave.bezier.containsPoint(point2) && cave.bezier.containsPoint(point3) && cave.bezier.containsPoint(point4)) {
                    return true
                }
            }
        case 2:
            for cave in cavesLayerTwo {
                if (cave.bezier.containsPoint(point1) && cave.bezier.containsPoint(point2) && cave.bezier.containsPoint(point3) && cave.bezier.containsPoint(point4)) {
                    return true
                }
            }
        case 3:
            for cave in cavesLayerThree {
                if (cave.bezier.containsPoint(point1) && cave.bezier.containsPoint(point2) && cave.bezier.containsPoint(point3) && cave.bezier.containsPoint(point4)) {
                    return true
                }
            }
        default:
            for cave in cavesLayerFour {
                if (cave.bezier.containsPoint(point1) && cave.bezier.containsPoint(point2) && cave.bezier.containsPoint(point3) && cave.bezier.containsPoint(point4)) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func addAnimationToView(viewNumber: Int) {
        animators[viewNumber]?.addBehavior(collider)
        
        gravity.addItem(player!)
        gravity.gravityDirection = CGVectorMake(0, 0)
        animators[viewNumber]?.addBehavior(gravity)
        
        collider.addItem(player!)
        
        switch viewNumber {
        case 0:
            for cave in cavesLayerZero {
                collider.addBoundaryWithIdentifier("cave", forPath: cave.bezier)
            }
        case 1:
            for cave in cavesLayerOne {
                collider.addBoundaryWithIdentifier("cave", forPath: cave.bezier)
            }
        case 2:
            for cave in cavesLayerTwo {
                collider.addBoundaryWithIdentifier("cave", forPath: cave.bezier)
            }
        case 3:
            for cave in cavesLayerThree {
                collider.addBoundaryWithIdentifier("cave", forPath: cave.bezier)
            }
        default:
            for cave in cavesLayerFour {
                collider.addBoundaryWithIdentifier("cave", forPath: cave.bezier)
            }
        }

        animators[viewNumber]?.addBehavior(collider)
        
        elasticity.addItem(player!)
        elasticity.elasticity = 0.2
        animators[viewNumber]?.addBehavior(elasticity)
    }
    
    func removeAnimationFromView(viewNumber: Int) {
        animators[viewNumber]?.removeAllBehaviors()
        gravity.removeItem(player!)
        collider.removeItem(player!)
        elasticity.removeItem(player!)
        collider.removeAllBoundaries()
    }
    
    func addMask(viewController: UIViewController, layerNumber: Int) {
        viewController.view.layer.mask = maskLayers[layerNumber]
        viewController.view.clipsToBounds = true
    }
    
    func buildMasks() {
        for layerNumber in 0 ... 4 {
            let maskLayer = CAShapeLayer()
            
            let path = UIBezierPath(rect: CGRect(x: CGFloat(0), y: CGFloat(0), width: self.view.bounds.maxX * 5, height: (CGFloat(nUnits/2) * self.view.bounds.maxY + CGFloat(nUnits/2) * self.view.bounds.maxY/4 + 2 * self.view.bounds.maxY)))
            
            switch layerNumber {
            case 0:
                for cave in cavesLayerZero {
                    path.appendPath(cave.bezier)
                }
            case 1:
                for cave in cavesLayerOne {
                    path.appendPath(cave.bezier)
                }
            case 2:
                for cave in cavesLayerTwo {
                    path.appendPath(cave.bezier)
                }
            case 3:
                for cave in cavesLayerThree {
                    path.appendPath(cave.bezier)
                }
            default:
                for cave in cavesLayerFour {
                    path.appendPath(cave.bezier)
                }
            }
            
            maskLayer.path = path.CGPath
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayers.append(maskLayer)
        }
    }
    
    func removeMask(viewController: UIViewController, layerNumber: Int)
    {
        viewController.view.layer.mask = nil
    }
    
    func drawCavesForMaze(viewController: UIViewController, layerNumber: Int, height: CGFloat, buffer: CGFloat) {
        let backLayer = CAShapeLayer()
        let length = CGFloat(nUnits/2) * height + CGFloat(nUnits/2) * buffer + 2 * height
        backLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: viewController.view.bounds.width*5, height: length)).CGPath
        backLayer.fillColor = Layers(rawValue: 5)?.color.CGColor
        viewController.view.layer.addSublayer(backLayer)
        shapeLayers[5].append(backLayer)
        
        
        var i = nLayers - 2
        while i >= layerNumber - 1 {
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: viewController.view.bounds.width*5, height: length))
            let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: viewController.view.bounds.width*5, height: length))
            
            switch i {
            case 0:
                for cave in cavesLayerZero {
                    path.appendPath(cave.bezier)
                    shadowPath.appendPath(cave.bezier)
                }
            case 1:
                for cave in cavesLayerOne {
                    path.appendPath(cave.bezier)
                    shadowPath.appendPath(cave.bezier)
                }
            case 2:
                for cave in cavesLayerTwo {
                    path.appendPath(cave.bezier)
                    shadowPath.appendPath(cave.bezier)
                }
            case 3:
                for cave in cavesLayerThree {
                    path.appendPath(cave.bezier)
                    shadowPath.appendPath(cave.bezier)
                }
            default:
                for cave in cavesLayerFour {
                    path.appendPath(cave.bezier)
                    shadowPath.appendPath(cave.bezier)
                }
            }
            
            let shadowLayer = CAShapeLayer()
            shadowLayer.shouldRasterize = true
            shadowLayer.rasterizationScale = UIScreen.mainScreen().scale
            shadowLayer.shadowPath = shadowPath.CGPath
            shadowLayer.fillRule = kCAFillRuleEvenOdd
            shadowLayer.shadowRadius = 7
            shadowLayer.shadowOffset = CGSizeMake(5, 5)
            shadowLayer.shadowColor = UIColor.blackColor().CGColor
            shadowLayer.shadowOpacity = 0.6
            shadowLayer.masksToBounds = false
            viewController.view.layer.addSublayer(shadowLayer)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.CGPath
            shapeLayer.fillRule = kCAFillRuleEvenOdd
            shapeLayer.fillColor = Layers(rawValue: i)?.color.CGColor
            viewController.view.layer.addSublayer(shapeLayer)
            shapeLayers[i].append(shapeLayer)
            
            i -= 1
        }
    }
    
    func doubleTapped() {
        colorPalette = (colorPalette + 1)%7
        colorLayers()
    }
    
    func colorLayers() {
        for i in 0 ... 5 {
            for layer in shapeLayers[i] {
                layer.fillColor = Layers(rawValue: i)?.color.CGColor
            }
        }
    }
    
    func makeUnits(width: CGFloat, height: CGFloat, buffer: CGFloat) {
        units = [[Unit?]](count: nUnits/2, repeatedValue: [Unit?](count: nLayers-1, repeatedValue: nil))
        for unit in 0 ... nUnits/2-1 {
            for layer in 0 ... nLayers-2 {
                if (layer == 0) {
                    units[unit][layer] = Unit(width: width, height: height, translation: CGPoint(x: width + CGFloat(unit%3) * width/2, y: CGFloat(unit)*height + CGFloat(unit)*buffer + height))
                } else {
                    units[unit][layer] = Unit(startBezier: units[unit][0]!.bezier, layerNumber: layer)
                }
            }
        }
    }
    
    func makeCavesFromUnits() {
        var unitsForCave = [Unit]()
        
        var previousLayerMerged = -1
        var layerToMerge = nLayers-2
        
        for j in 0 ... nUnits/2-1 {
            for layer in 0 ... nLayers-2 {
                if (layer == layerToMerge && j != nUnits/2-1) {
                    unitsForCave.append(units[j][layer]!)
                    unitsForCave.append(units[j+1][layer]!)
                } else if (layer != previousLayerMerged) {
                    unitsForCave.append(units[j][layer]!)
                }
                
                if (layer == 0 && layer != previousLayerMerged) {
                    cavesLayerZero.append(Cave(units: unitsForCave))
                } else if (layer == 1 && layer != previousLayerMerged) {
                    cavesLayerOne.append(Cave(units: unitsForCave))
                } else if (layer == 2 && layer != previousLayerMerged) {
                    cavesLayerTwo.append(Cave(units: unitsForCave))
                } else if (layer == 3 && layer != previousLayerMerged) {
                    cavesLayerThree.append(Cave(units: unitsForCave))
                } else if (layer == 4 && layer != previousLayerMerged) {
                    cavesLayerFour.append(Cave(units: unitsForCave))
                }
                unitsForCave.removeAll()
            }
            previousLayerMerged = layerToMerge
            layerToMerge = (layerToMerge + 3)%(nLayers-1)
        }
    }
    
    func generateOrganicShape() -> UIBezierPath {
        
        let buffer: CGFloat = 5
        
        let x1a = CGRectGetMinX(self.view.frame)
        let x1b = CGRectGetMaxX(self.view.frame)/3 - buffer
        
        let x2a = CGRectGetMaxX(self.view.frame)/3 + buffer
        let x2b = 2 * CGRectGetMaxX(self.view.frame)/3 - buffer
        
        let x3a = 2 * CGRectGetMaxX(self.view.frame)/3 + buffer
        let x3b = CGRectGetMaxX(self.view.frame)
        
        let y1a = CGRectGetMinY(self.view.frame)
        let y1b = CGRectGetMaxY(self.view.frame)/3 - buffer
        
        let y2a = CGRectGetMaxY(self.view.frame)/3 + buffer
        let y2b = 2 * CGRectGetMaxY(self.view.frame)/3 - buffer
        
        let y3a = 2 * CGRectGetMaxY(self.view.frame)/3 + buffer
        let y3b = CGRectGetMaxY(self.view.frame)
        
        
        let p1 = randomPointInRange(x1a, hiX: x1b, loY: y3a, hiY: y3b)
        let p2 = randomPointInRange(x2a, hiX: x2b, loY: y3a, hiY: y3b)
        let p3 = randomPointInRange(x3a, hiX: x3b, loY: y3a, hiY: y3b)
        let p4 = randomPointInRange(x3a, hiX: x3b, loY: y2a, hiY: y2b)
        let p5 = randomPointInRange(x3a, hiX: x3b, loY: y1a, hiY: y1a)
        let p6 = randomPointInRange(x2a, hiX: x2b, loY: y1a, hiY: y1a)
        let p7 = randomPointInRange(x1a, hiX: x1b, loY: y1a, hiY: y1b)
        let p8 = randomPointInRange(x2a, hiX: x2b, loY: y2a, hiY: y2b)
        
        
        let points: Array = [NSValue(CGPoint: p1), NSValue(CGPoint: p2), NSValue(CGPoint: p3), NSValue(CGPoint: p4), NSValue(CGPoint: p5), NSValue(CGPoint: p6), NSValue(CGPoint: p7), NSValue(CGPoint: p8)]
        
        return UIBezierPath.interpolateCGPointsWithCatmullRom(points, closed: true, alpha: 0.5)
    }
    
    func shoudAnimate() -> Bool {
        let window = view.window
        let pointInWindow = player?.superview!.convertPoint((player?.center)!, toView: nil)
        let pointInScreen = window?.convertPoint(pointInWindow!, toWindow: nil)
        
        let minimumY = self.view.bounds.height/7
        let maximumY = 6*self.view.bounds.height/7
        
        let minimumX = self.view.bounds.width/7
        let maximumX = 6*self.view.bounds.width/7
        
        if ((pointInScreen!.y < minimumY || pointInScreen!.y > maximumY || pointInScreen!.x < minimumX || pointInScreen!.x > maximumX) && !caveIsAnimating && !pageIsAnimating) {
            return true
        }
        else {
            return false
        }
        
    }
    
    func animateCaves() {
        let window = view.window
        let pointInWindow = player?.superview!.convertPoint((player?.center)!, toView: nil)
        let pointInScreen = window?.convertPoint(pointInWindow!, toWindow: nil)
        
        let centerInWindow = self.view.superview?.convertPoint(self.view.center, toView: nil)
        let centerInScreen = window?.convertPoint(centerInWindow!, toWindow: nil)
        
        let minimumY = self.view.bounds.height/7
        let maximumY = 6*self.view.bounds.height/7
        
        let minimumX = self.view.bounds.width/7
        let maximumX = 6*self.view.bounds.width/7
        
        if ((pointInScreen!.y < minimumY || pointInScreen!.y > maximumY || pointInScreen!.x < minimumX || pointInScreen!.x > maximumX) && !caveIsAnimating && !pageIsAnimating) {
            caveIsAnimating = true
            let newOffset = CGPointMake(scrollViews[0].contentOffset.x - (centerInScreen!.x - pointInScreen!.x), scrollViews[0].contentOffset.y - (centerInScreen!.y - pointInScreen!.y))
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                for i in 0 ... self.nLayers - 2 {
                    self.scrollViews[i].contentOffset = newOffset
                }}, completion: {(value: Bool) in
                    self.caveIsAnimating = false
            })
        }
    }
    
    func playMusic() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: music)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("No Sound Found: " + String(error))
        }
    }
    
    func playPageSound() {
        do {
            try audioPlayerPage = AVAudioPlayer(contentsOfURL: pageSound)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            audioPlayerPage.numberOfLoops = 1
            audioPlayerPage.volume = 0.1
            audioPlayerPage.prepareToPlay()
            audioPlayerPage.play()
        } catch {
            print("No Sound Found: " + String(error))
        }
    }
}

