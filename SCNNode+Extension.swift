//
//  SCNNode+Extension.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation
import SceneKit

extension SCNNode {
    func setNodeToOccluder() {
        let material = SCNMaterial(diffuse: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        material.colorBufferWriteMask = []
        material.writesToDepthBuffer = true
        
        guard let geometry = geometry else { fatalError("Node has no geometry") }
        geometry.materials = [material]
        renderingOrder = -10
        castsShadow = false
    }
}
