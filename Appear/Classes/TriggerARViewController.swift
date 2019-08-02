//
//  TriggerARViewController.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import UIKit
import SpriteKit
import SceneKit
import SceneKit.ModelIO
import ARKit
import AVFoundation
import AVKit

public enum MediaContentMode {
    case scaleToFill
    case apsectFill
}

public struct VideoObject {
    let name: String
    let url: URL
    let aspectRatio: Double
}

@available(iOS 12.0, *)
public class TriggerARViewController: UIViewController {
    
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var tutorialView: UIView = {
        let view = SimpleTutorialView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var models: [SCNNode] = []
    var videos: [VideoObject] = []
    private var modelUrl: URL?
    let viewModel: SimpleARViewModel = SimpleARViewModel()
    private var customReferenceSet = Set<ARReferenceImage>()
    private var customOjectReferenceSet = Set<ARReferenceObject>()
    var contentMode = MediaContentMode.scaleToFill
    var initialAppear = true
    
    
    /// View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        
        //Add recognizer to sceneview
        sceneView.addGestureRecognizer(tap)
        
        setupViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        guard initialAppear else {
            sceneView.session.run(sceneView.session.configuration!)
            for node in sceneView.scene.rootNode.childNodes {
                if let videoNode = node as? AppearVideoNode {
                    print(videoNode.name)
                    videoNode.avPlayer.play()
                }
            }
            return
        }
        
        initialAppear = false
        let group = DispatchGroup()
        
        // make sure the tutorial view is visible for more than 3 seconds
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            group.leave()
        }
        
        viewModel.fetchProject { (result) in
            switch result {
            case .success(let project):
                print("successfully fetched project with id: \(project.id)")
                for item in project.items {
                    // Handle triggers
                    group.enter()
                    print("fetching trigger object archive url from item with name: \(item.name)")
                    self.viewModel.fetchTriggerArchiveUrl(from: item, completion: { (result) in
                        switch result {
                        case .success(let url):
                            print("Successfully fetched object archive url")
                            switch item.trigger.type {
                            case .image:
                                do {
                                    let data = try Data.init(contentsOf: url)
                                    guard let cgImage = UIImage(data: data)?.cgImage else { fatalError() }
                                    guard let trigger = item.trigger as? AppearProjectItem.ImageMedia, let width = trigger.width else { fatalError()}
                                    let referenceImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(width/100))
                                    referenceImage.name = item.name
                                    self.customReferenceSet.insert(referenceImage)
                                    group.leave()
                                } catch (let error) {
                                    fatalError(error.localizedDescription)
                                }
                            case .object:
                                do {
                                    let object = try ARReferenceObject(archiveURL: url)
                                    object.name = item.name
                                    self.customOjectReferenceSet.insert(object)
                                    group.leave()
                                } catch (let error) {
                                    fatalError(error.localizedDescription)
                                }
                            }
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        }
                    })
                }
                
                group.notify(queue: DispatchQueue.main) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        self.tutorialView.alpha = 0
                    }, completion: { (_) in
                        self.tutorialView.isHidden = true
                    })
                    self.setupTracking()
                }
                
            case .failure(let error):
                guard let error = error as? AppearError else { fatalError() }
                self.presentAlert(campaignError: error)
            }
        }
    }
    
    func setupViews() {
        self.view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        self.view.addSubview(tutorialView)
        NSLayoutConstraint.activate([
            tutorialView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tutorialView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tutorialView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tutorialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
        
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                print(tappedNode?.name)
                for hit in hits {
                    for item in viewModel.triggers {
                        for media in item.0.media {
                            if hit.node.name == "ImageLoader" {
                                for childNode in hit.node.childNodes {
                                    if childNode.name == media.name {
                                        print("\(media.name) was hit!!!!")
                                        handleSuccessfullTap(on: hit.node, of: media.type)
                                    }
                                }
                            }
                            if hit.node.name == media.name {
                                print("\(media.name) was hit!!!!")
                                handleSuccessfullTap(on: hit.node, of: media.type)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func handleSuccessfullTap(on node: SCNNode, of type: AppearProjectItem.MediaType ) {
        switch type {
        case .model:
            node.removeAllAnimations()
        case .video:
            if let videoNode = node as? AppearVideoNode {
                let playerController = AVPlayerViewController()
                DispatchQueue.main.async {
                    playerController.player = videoNode.avPlayer
                    self.present(playerController, animated: true, completion: {
                        playerController.player!.play()
                    })
                }
            }
        }
    }
    
    @available(iOS 12.0, *)
    private func setupTracking(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = self.customReferenceSet
        configuration.detectionObjects = self.customOjectReferenceSet
        configuration.maximumNumberOfTrackedImages = self.customReferenceSet.count
        configuration.isLightEstimationEnabled = true
        configuration.environmentTexturing = .automatic
        //self.sceneView.debugOptions = ARSCNDebugOptions(arrayLiteral: [.showBoundingBoxes, .showPhysicsShapes, .showWorldOrigin, .showCameras])
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func getModel(from url: URL) -> SCNNode?{
        do {
            let shipScene = try SCNScene.init(url: url, options: nil)
            print(shipScene.rootNode.scale)
            print(shipScene.rootNode.boundingBox)
            return shipScene.rootNode // shipNode
        } catch (let error) {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func initAspectRatioOfVideo(with fileURL: URL) -> Double? {
        let resolution = resolutionForLocalVideo(url: fileURL)
        
        guard let width = resolution?.width, let height = resolution?.height else {
            return nil
        }
        
        print("height: \(height)")
        print("width: \(width)")
        return Double(width / height)
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
