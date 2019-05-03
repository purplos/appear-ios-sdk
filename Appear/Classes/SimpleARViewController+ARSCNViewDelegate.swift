//
//  SimpleARViewController+ARSCNViewDelegate.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import ARKit

// MARK: - ARSCNViewDelegate
@available(iOS 12.0, *)
extension SimpleARViewController: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor =  anchor as? ARImageAnchor {
            let imageSize = imageAnchor.referenceImage.physicalSize
            
            let plane = SCNPlane(width: CGFloat(imageSize.width), height: CGFloat(imageSize.height))
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            
            if let model = models.first(where: { $0.name == imageAnchor.referenceImage.name}) {
                print("\(String(describing: imageAnchor.referenceImage.name)) detected as model")
                planeNode.setNodeToOccluder()
                
                // create and add a light to the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light!.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
                model.addChildNode(lightNode)
                
                // scale so that test model will be correct size
                model.scale = SCNVector3(0.4, 0.4, 0.4)
                
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
                model.addChildNode(ambientLightNode)
                
                model.position.x = planeNode.position.x
                model.position.y = planeNode.position.y
                model.position.z = planeNode.position.z + (model.boundingBox.max.z*0.4 - model.boundingBox.min.z*0.4)/2
                
                planeNode.addChildNode(model)
            }
            
            if let video = videos.first(where: { $0.name == imageAnchor.referenceImage.name}) {
                let avPlayerItem = AVPlayerItem(url: video.url)
                let avPlayer = AVPlayer(playerItem: avPlayerItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    avPlayer.play()
                }
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: nil,
                    queue: nil) { notification in
                        avPlayer.seek(to: .zero)
                        avPlayer.play()
                }
                
                let avMaterial = SCNMaterial()
                avMaterial.diffuse.contents = avPlayer
                
                planeNode.geometry?.materials = [avMaterial]
                
            }
            
            node.addChildNode(planeNode)
            
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Error didFailWithError: \(error.localizedDescription)")
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Error sessionWasInterrupted: \(session.debugDescription)")
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("Error sessionInterruptionEnded : \(session.debugDescription)")
    }
}

@available(iOS 12.0, *)
extension SimpleARViewController: ARSessionDelegate {
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            print(".notAvailable")
        case .limited(_):
            print("limited")
        case .normal:
            print("normal")
        }
    }
}
