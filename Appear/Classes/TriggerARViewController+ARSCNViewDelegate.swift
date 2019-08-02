//
//  TriggerARViewController+ARSCNViewDelegate.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import ARKit

typealias URLWithMediaType = ()
typealias MediaWithArchiveURL = (media: MediaProtocol, archiveURL: URL)
typealias CompletionHandler = (Result<[MediaWithArchiveURL]>) -> Void
typealias MediaWithNode = (media: MediaProtocol, node: SCNNode)

// MARK: - ARSCNViewDelegate
@available(iOS 12.0, *)
extension TriggerARViewController: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Handle a detected object
        if let objectAnchor = anchor as? ARObjectAnchor {
            let name = objectAnchor.referenceObject.name!
            print("Object detected! :) ")
            print("You found a \(name) object")
            displayLoader(on: objectAnchor, node: node)
            guard let detectedTriggerItem = detectedTriggerItem(with: name) else { fatalError() }
            fetchMediaWithArchiveURL(from: detectedTriggerItem) { (result) in
                switch result {
                case .success(let mediaWithArchiveURLArray):
                    let group = DispatchGroup()
                    var animatableNodes: [MediaWithNode] = []
                    for mediaWithArchiveURL in mediaWithArchiveURLArray {
                        switch mediaWithArchiveURL.media.type {
                        case .model:
                            guard let modelMedia = mediaWithArchiveURL.media as? AppearProjectItem.ModelMedia else { fatalError() }
                            group.enter()
                            self.createModel(from: mediaWithArchiveURL.archiveURL,
                                             with: modelMedia,
                                             relativeTo: node,
                                             for: anchor,
                                             completion: { (result) in
                                                switch result {
                                                case .success(let modelNode):
                                                    animatableNodes.append((media: modelMedia, node: modelNode))
                                                    group.leave()
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
                            })
                        case .video:
                            guard let videoMedia = mediaWithArchiveURL.media as? AppearProjectItem.VideoMedia else { fatalError() }
                            group.enter()
                            self.createVideo(from: mediaWithArchiveURL.archiveURL,
                                             with: videoMedia,
                                             relativeTo: node,
                                             for: anchor,
                                             completion: { (result) in
                                                switch result {
                                                case .success(let videoNode):
                                                    animatableNodes.append((media: videoMedia, node: videoNode))
                                                    group.leave()
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
                            })
                        }
                    }
                    group.notify(queue: DispatchQueue.main) {
                        print("group.notify")
                        // animate nodes. Use delay on media to time the animations
                        self.hideObjectLoader(node: node, completion: {
                            for animatableNode in animatableNodes {
                                switch animatableNode.media.type {
                                case .model:
                                    guard let media = animatableNode.media as? AppearProjectItem.ModelMedia else { fatalError() }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(media.delay ?? 0), execute: {
                                        node.addChildNode(animatableNode.node)
                                        let popIn = SCNAction.scale(to: CGFloat(media.scale), duration: 0.5)
                                        popIn.timingMode = SCNActionTimingMode.easeInEaseOut
                                        animatableNode.node.runAction(popIn)
                                    })
                                case .video:
                                    guard let media = animatableNode.media as? AppearProjectItem.VideoMedia else { fatalError() }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(media.delay ?? 0), execute: {
                                        node.addChildNode(animatableNode.node)
                                        let fadeIn = SCNAction.fadeOpacity(to: 1, duration: 0.5)
                                        fadeIn.timingMode = SCNActionTimingMode.easeInEaseOut
                                        animatableNode.node.runAction(fadeIn)
                                    })
                                }
                            }
                            print(animatableNodes.count)
                        })
                    }
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        //Handle a detected image
        if let imageAnchor =  anchor as? ARImageAnchor {
            
            let name = imageAnchor.referenceImage.name!
            let planeNode = ImageTriggerPlaneNode(planeSize: imageAnchor.referenceImage.physicalSize)
            node.addChildNode(planeNode)
            planeNode.startLoading()
            guard let detectedTriggerItem = detectedTriggerItem(with: name) else { fatalError() }
            fetchMediaWithArchiveURL(from: detectedTriggerItem) { (result) in
                switch result {
                case .success(let mediaWithArchiveURLArray):
                    let group = DispatchGroup()
                    var animatableNodes: [MediaWithNode] = []
                    for mediaWithArchiveURL in mediaWithArchiveURLArray {
                        switch mediaWithArchiveURL.media.type {
                        case .model:
                            guard let modelMedia = mediaWithArchiveURL.media as? AppearProjectItem.ModelMedia else { fatalError() }
                            group.enter()
                            print("enter")
                            self.createModel(from: mediaWithArchiveURL.archiveURL,
                                             with: modelMedia,
                                             relativeTo: planeNode,
                                             for: anchor,
                                             completion: { (result) in
                                                switch result {
                                                case .success(let modelNode):
                                                    animatableNodes.append((media: modelMedia, node: modelNode))
                                                    group.leave()
                                                    print("leave")
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
                            })
                        case .video:
                            guard let videoMedia = mediaWithArchiveURL.media as? AppearProjectItem.VideoMedia else { fatalError() }
                            group.enter()
                            print("enter")
                            self.createVideo(from: mediaWithArchiveURL.archiveURL,
                                             with: videoMedia,
                                             relativeTo: planeNode,
                                             for: anchor,
                                             completion: { (result) in
                                                switch result {
                                                case .success(let videoNode):
                                                    animatableNodes.append((media: videoMedia, node: videoNode))
                                                    group.leave()
                                                    print("leave")
                                                    print(animatableNodes.count)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
                            })
                        }
                    }
                    
                    group.notify(queue: DispatchQueue.main) {
                        print("group.notify")
                        // animate nodes. Use delay on media to time the animations
                        self.stopPlaneLoading(node: node, completion: {
                            for animatableNode in animatableNodes {
                                switch animatableNode.media.type {
                                case .model:
                                    guard let media = animatableNode.media as? AppearProjectItem.ModelMedia else { fatalError() }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(media.delay ?? 0), execute: {
                                        planeNode.addChildNode(animatableNode.node)
                                        let popIn = SCNAction.scale(to: CGFloat(media.scale), duration: 0.5)
                                        popIn.timingMode = SCNActionTimingMode.easeInEaseOut
                                        animatableNode.node.runAction(popIn)
                                    })
                                case .video:
                                    guard let media = animatableNode.media as? AppearProjectItem.VideoMedia else { fatalError() }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(media.delay ?? 0), execute: {
                                        planeNode.addChildNode(animatableNode.node)
                                        let fadeIn = SCNAction.fadeOpacity(to: 1, duration: 0.5)
                                        fadeIn.timingMode = SCNActionTimingMode.easeInEaseOut
                                        animatableNode.node.runAction(fadeIn)
                                    })
                                }
                            }
                            print(animatableNodes.count)
                        })
                    }
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    private func detectedTriggerItem (with name: String) -> AppearProjectItem? {
        return viewModel.triggers.first(where: {$0.0.name == name})?.0
    }
    
    private func stopPlaneLoading(node: SCNNode, completion: @escaping () -> Void) {
        guard let planeNode = node.childNodes.first(where: { $0.name == "ImageLoader"}) as? ImageTriggerPlaneNode else { fatalError() }
        planeNode.stopLoading(removeFromParent: false) {
            completion()
        }
    }
    
    private func displayLoader(on objectAnchor: ARObjectAnchor, node: SCNNode) {
        let loaderNode = LoaderObjectNode(featurePoints: objectAnchor.referenceObject.rawFeaturePoints)
        node.addChildNode(loaderNode)
    }
    
    private func hideObjectLoader(node: SCNNode, completion: @escaping () -> Void) {
        guard let objectLoaderNode = node.childNodes.first(where: { $0.name == "ObjectLoader"}) as? LoaderObjectNode else { fatalError() }
        objectLoaderNode.animateOut(removeFromParent: true, completion: {
            completion()
        })
    }
    
    private func fetchMediaWithArchiveURL(from item: AppearProjectItem, completion: @escaping CompletionHandler) {
        let group = DispatchGroup()
        var mediaWithArchiveURLsArray: [MediaWithArchiveURL] = []
        for media in item.media {
            group.enter()
            fetchArchiveURL(from: media) { (result) in
                switch result {
                case .success(let archiveURL):
                    mediaWithArchiveURLsArray.append((media: media, archiveURL: archiveURL))
                    group.leave()
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion(Result.success(mediaWithArchiveURLsArray))
        }
    }
    
    private func fetchArchiveURL(from media: MediaProtocol, completion: @escaping (Result<URL>) -> Void) {
        viewModel.fetchMediaUrl(from: media) { (result) in
            switch result {
            case .success(let url):
                completion(Result.success(url))
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func createModel(from url: URL, with media: AppearProjectItem.ModelMedia, relativeTo node: SCNNode, for anchor: ARAnchor, completion: @escaping (Result<SCNNode>) -> Void) {
        // get a global concurrent queue
        DispatchQueue.global(qos: .background).async {
            do {
                let scene = try SCNScene.init(url: url, options: nil)
                let modelNode = scene.rootNode
                
                // set name
                modelNode.name = media.name
                
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
                
                // scale so that test model will be correct size
                modelNode.scale = SCNVector3(0, 0, 0)
                
                if let objectAnchor = anchor as? ARObjectAnchor {
                    // Set position of model relative to the object
                    modelNode.position = SCNVector3(objectAnchor.referenceObject.center.x + Float(media.position?[0] ?? 0.0), objectAnchor.referenceObject.center.y + Float(media.position?[1] ?? 0.0), objectAnchor.referenceObject.center.z + Float(media.position?[2] ?? 0.0))
                    completion(Result.success(modelNode))
                    
                } else if let imageAnchor = anchor as? ARImageAnchor {
                    
                    print(imageAnchor.referenceImage.name ?? "")
                    
                    // Set position of model relative to the plane
                    modelNode.position = SCNVector3(node.position.x + Float(media.position?[0] ?? 0.0),
                                                    node.position.y + Float(media.position?[1] ?? 0.0),
                                                    node.position.z + Float(media.position?[2] ?? 0.0))
                    
                    // Add to scene
                    let modelNodeClone = modelNode.clone()
                    completion(Result.success(modelNodeClone))
                }
                
            } catch (let error) {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func createVideo(from url: URL, with media: AppearProjectItem.VideoMedia , relativeTo node: SCNNode, for anchor: ARAnchor, completion: @escaping (Result<SCNNode>) -> Void) {
            DispatchQueue.global(qos: .background).async {
                if let objectAnchor = anchor as? ARObjectAnchor {
                    let videoNode = AppearVideoNode(videoArchiveURL: url, media: media)
                    videoNode.opacity = 0
                    videoNode.position = SCNVector3(objectAnchor.referenceObject.center.x + Float(media.position?[0] ?? 0.0),
                                                    objectAnchor.referenceObject.center.y + Float(media.position?[1] ?? 0.0),
                                                    objectAnchor.referenceObject.center.z + Float(media.position?[2] ?? 0.0))
                    completion(Result.success(videoNode))
                    
                } else if let imageAnchor = anchor as? ARImageAnchor {
                    let imageSize = imageAnchor.referenceImage.physicalSize
                    let videoNode = AppearVideoNode(videoArchiveURL: url, media: media)
                    switch media.contentMode {
                    case .scaleToFill:
                        videoNode.plane.width = CGFloat(imageSize.width)
                        videoNode.plane.height =  CGFloat(imageSize.height)
                    case .aspectFill:
                        videoNode.plane.height = CGFloat(imageSize.height)
                        guard let url = self.urlOfCurrentlyPlaying(in: videoNode.avPlayer) else { fatalError() }
                        let resolution = self.resolutionSizeForLocalVideo(url: url)
                        let ratio = CGFloat(resolution!.width/resolution!.height)
                        let width = imageSize.height * ratio
                        videoNode.plane.width = width
                    }
                    
                    videoNode.plane.width = videoNode.plane.width * CGFloat(media.scale ?? 1)
                    videoNode.plane.height = videoNode.plane.height * CGFloat(media.scale ?? 1)
                    
                    videoNode.position.x = videoNode.position.x + Float((media.position?[0] ?? 0))
                    videoNode.position.y = videoNode.position.y + Float((media.position?[2] ?? 0))
                    videoNode.position.z = videoNode.position.z + Float((media.position?[1] ?? 0))
                    
                    print("video added to scene")
                    videoNode.opacity = 0
                    completion(Result.success(videoNode))
                }
            }
    }
    
    func resolutionSizeForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    private func urlOfCurrentlyPlaying(in player: AVPlayer) -> URL? {
        return ((player.currentItem?.asset) as? AVURLAsset)?.url
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
extension TriggerARViewController: ARSessionDelegate {
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
