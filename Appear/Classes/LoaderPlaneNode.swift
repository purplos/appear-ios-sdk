//
//  LoaderPlaneNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 09/07/2019.
//

import UIKit
import SceneKit


class ImageTriggerPlaneNode: SCNNode {
    
    var plane: SCNPlane!
    
    init(planeSize: CGSize) {
        super.init()
        self.name = "ImageLoader"
        self.plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        self.geometry = plane
        self.eulerAngles.x = -.pi / 2
        self.opacity = 0
    }
    
    func startLoading() {
        self.plane.cornerRadius = self.plane.width/20
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        startBlinkingAnimation(1)
    }
    
    func stopLoading(removeFromParent: Bool, completion: @escaping () -> Void) {
        animateOut {
            if removeFromParent {
                self.removeFromParentNode()
            }
            completion()
        }
    }
    
    private func startBlinkingAnimation(_ duration: TimeInterval) {
        
            let fadeIn = SCNAction.fadeOpacity(to: 1, duration: duration)
            let fadeOut = SCNAction.fadeOpacity(to: 0, duration: duration)
            
            //3. Create An SCNAction Sequence Which Runs The Actions
            let pulseSequence = SCNAction.sequence([fadeIn, fadeOut])
            
            //4. Set The Loop As Infinitie
            let infiniteLoop = SCNAction.repeatForever(pulseSequence)
            
            //5. Run The Action
            self.runAction(infiniteLoop)
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 0.5)
        self.removeAllActions()
        self.runAction(fadeOut) {
            self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0)
            self.opacity = 1
            completion()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
