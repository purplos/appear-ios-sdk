//
//  FeatureNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 10/07/2019.
//

import UIKit
import SceneKit

class FeatureNode: SCNNode {
    
    var sphereNode: SCNSphere!
    
    init(radius: CGFloat) {
        super.init()
        self.name = "loader"
        self.sphereNode = SCNSphere(radius: radius)
        self.geometry = sphereNode
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.9)
        self.opacity = 0
        let randomInt = Int.random(in: 0...6000)
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(randomInt)) {
            self.startBlinkingAnimation(0.5, repeatTime: 4)
        }
    }
    
    private func startBlinkingAnimation(_ duration: TimeInterval, repeatTime: TimeInterval) {
        
        //Create SCNActions
        let fadeIn = SCNAction.fadeOpacity(to: 1, duration: duration)
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: duration)
        let sleep = SCNAction.wait(duration: repeatTime)
        
        // Create An SCNAction Sequence Which Runs The Actions
        let pulseSequence = SCNAction.sequence([fadeIn, fadeOut, sleep])
        
        // Set The Loop As Infinitie
        let infiniteLoop = SCNAction.repeatForever(pulseSequence)
        
        // Run The Action
        self.runAction(infiniteLoop)
    }
    
    func animateOut(removeFromParent: Bool, completion: @escaping () -> Void) {
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 1)
        self.runAction(fadeOut) {
            if removeFromParent {
                self.removeFromParentNode()
                completion()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
