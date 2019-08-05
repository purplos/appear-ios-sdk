//
//  AppearModelNode.swift
//  Appear
//
//  Created by Magnus Tviberg on 10/07/2019.
//

import Foundation
import SceneKit

public class AppearModelNode: SCNNode {
    public init(archiveURL: URL, modelMedia: AppearProjectItem.ModelMedia) {
        super.init()
        do {
            let scene = try SCNScene.init(url: archiveURL, options: nil)
            let modelNode = scene.rootNode
            self.addChildNode(modelNode.clone())
            // set name
            self.name = modelMedia.name
            
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
        } catch (let error) {
            fatalError(error.localizedDescription)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
