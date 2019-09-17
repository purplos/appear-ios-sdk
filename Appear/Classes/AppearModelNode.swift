//
//  AppearModelNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 10/07/2019.
//

import Foundation
import SceneKit
import ARKit

@available(iOS 12.0, *)
public class AppearModelNode: SCNNode {
    public init(archiveURL: URL, modelMedia: AppearProjectItem.ModelMedia, node: SCNNode? = nil, anchor: ARAnchor? = nil) {
        super.init()
        do {
            let scene = try SCNScene.init(url: archiveURL, options: nil)
            let modelNode = scene.rootNode.clone()
            self.addChildNode(modelNode)
            
            // set name
            self.name = modelMedia.name
            
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = [.X, .Y]
            self.constraints?.append(constraint)
            
            // create and add a light to the scene
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            //modelNode.addChildNode(lightNode)
            
            // create and add an ambient light to the scene
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = .ambient
            ambientLightNode.light!.color = UIColor.darkGray
            //modelNode.addChildNode(ambientLightNode)
            
            if let objectAnchor = anchor as? ARObjectAnchor {
                // Set position of model relative to the object
                self.position = SCNVector3(objectAnchor.referenceObject.center.x + Float(modelMedia.position?[0] ?? 0.0),
                                           objectAnchor.referenceObject.center.y + Float(modelMedia.position?[1] ?? 0.0),
                                           objectAnchor.referenceObject.center.z + Float(modelMedia.position?[2] ?? 0.0))
                
            } else if anchor is ARImageAnchor {
                // Set position of model relative to the plane
                guard let node = node else {
                    self.position = SCNVector3(0, 0, 0)
                    return
                }
                self.position = SCNVector3(node.position.x + Float(modelMedia.position?[0] ?? 0.0),
                                           node.position.y + Float(modelMedia.position?[1] ?? 0.0),
                                           node.position.z + Float(modelMedia.position?[2] ?? 0.0))
            }
            
        } catch (let error) {
            AppearLogger().errorPrint(error.localizedDescription)
            AppearLogger().fatalErrorPrint(AppearError.unableToCreateModelFromURL.errorMessage)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
