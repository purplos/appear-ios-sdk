//
//  SCNMaterial+Extension.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation
import SceneKit

extension SCNMaterial {
    convenience init(diffuse: Any?) {
        self.init()
        self.diffuse.contents = diffuse
        isDoubleSided = true
        lightingModel = .physicallyBased
    }
}

