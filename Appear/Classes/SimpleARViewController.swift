//
//  SimpleARViewController.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import UIKit
import SpriteKit
import SceneKit
import SceneKit.ModelIO
import ARKit

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
public class SimpleARViewController: UIViewController {
    
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
    private let viewModel: SimpleARViewModel = SimpleARViewModel()
    private var customReferenceSet = Set<ARReferenceImage>()
    var contentMode = MediaContentMode.scaleToFill
    
    
    /// View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        setupViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchProject { (result) in
            
            switch result {
            case .success(let project):
                for item in project.items {
                    let image = UIImage(data: item.image.data)!
                    let arImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(item.image.width))
                    
                    arImage.name = item.name
                    self.customReferenceSet.insert(arImage)
                    
                    switch item.type {
                    case .model:
                        guard let model = self.getModel(from: item.media.localURL) else {
                            print(item.media.localURL)
                            self.presentAlert(campaignError: AppearError.localModelUrlMissing)
                            return
                        }
                        model.name = item.name
                        self.models.append(model)
                        
                    case .video:
                        if let aspectRatio = self.initAspectRatioOfVideo(with: item.media.localURL) {
                            let videoObject = VideoObject(name: item.name, url: item.media.localURL, aspectRatio: aspectRatio)
                            self.videos.append(videoObject)
                            
                        }
                    }
                }
                
                UIView.animate(withDuration: 0.5, delay: 3.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.tutorialView.alpha = 0
                }, completion: { (_) in
                    self.tutorialView.isHidden = true
                })
                self.setupImageTracking()
                
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
    
    @available(iOS 12.0, *)
    private func setupImageTracking(){
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = self.customReferenceSet
        configuration.maximumNumberOfTrackedImages = self.customReferenceSet.count
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
