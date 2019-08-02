//
//  LoaderObjectNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 10/07/2019.
//

import UIKit
import SceneKit
import ARKit


class LoaderObjectNode: SCNNode {
    
    var featureNodes: [FeatureNode]!
    
    init(featurePoints: ARPointCloud) {
        super.init()
        self.name = "ObjectLoader"
        for point in featurePoints.points {
            let position = SCNVector3(point.x, point.y, point.z)
            addFeature(position)
        }
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
    
    private func addFeature(_ position: SCNVector3) {
        let featureNode = FeatureNode(radius: 0.0009)
        featureNode.position = position
        self.addChildNode(featureNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
