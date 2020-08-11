//
//  RealityFileViewController.swift
//  Appear
//
//  Created by Magnus Tviberg on 04/12/2019.
//

import UIKit
import RealityKit
import Combine
import ARKit

@available(iOS 13.0, *)
public class RealityProjectViewController: UIViewController {

    lazy var arView: ARView = {
        let view = ARView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var tutorialView: UIView = {
        let view = SimpleTutorialView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public func onAction(handler: @escaping (_ identifier: String, _ entity: RealityKit.Entity?) -> Void) {
        actionHandler = handler
    }
    
    /// A Boolean value specifying whether the first detected plane should have an occlusion material.
    /// By default isOcclusionFloorEnabled is set to false
    public var isOcclusionFloorEnabled = false
    
    /// A Boolean value specifying whether people occlusion should be added to the ARConfiguration
    /// By default isOcclusionFloorEnabled is set to false
    public var isPeopleOcclusionEnabled = false
    
    private var actionHandler: ((String, RealityKit.Entity?) -> Void)?
    private var identifier: String?
    private let realityViewModel = RealityProjectViewModel()
    private var subscribers = Set<AnyCancellable>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startARExperience()
        self.realityViewModel.manager.delegate = self
        self.realityViewModel.manager.setupActionListener()
    }
    
    public func configure(withIdentifier identifier: String) {
        self.identifier = identifier
    }
    
    public func sendAction(withIdentifier identifier: String, entityName: String) {
        guard let entity = arView.scene.findEntity(named: entityName) else { fatalError() }
        sendAction(withIdentifier: identifier, entity: entity)
    }
    
    public func sendAction(withIdentifier identifier: String, entity: Entity) {
        realityViewModel.manager.sendAction(withIdentifier: identifier, entity: entity)
    }
    
    private func startARExperience() {
        if let id = identifier {
            loadAnchorsFromMedia(with: id)
        } else {
            loadAnchorsByFetchingProject()
        }
    }
    
    private func loadAnchorsFromMedia(with id: String) {
        realityViewModel.fetchRealityMedia(withID: id) { (result) in
            switch result {
            case .success(let media):
                self.fetchAllActiveMediaURLs(media: [media]) { (result) in
                    switch result {
                    case .success(let urls):
                        self.loadAnchors(from: urls)
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func loadAnchorsByFetchingProject() {
        realityViewModel.fetchProject { (result) in
            switch result {
            case .success(let project):
                self.fetchAllActiveMediaURLs(media: project.media) { (result) in
                    switch result {
                    case .success(let urls):
                        self.loadAnchors(from: urls)
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func loadAnchors(from urls: [URL]) {
        
        let group = DispatchGroup()
        var configurations: [ARConfiguration] = []
        var anchors: [AnchorEntity] = []
        
        for url in urls {
            group.enter()
            self.addEntityToAnchor(url: url) { (config, anchor, error) in
                guard error == nil else {
                    self.presentAlert(campaignError: error!) { (_) in }
                    return
                }
                guard let anchor = anchor else {
                    self.presentAlert(campaignError: AppearError.errorWithMessage("no anchor")) { (_) in }
                    return
                }
                if let config = config {
                    configurations.append(config)
                }
                anchors.append(anchor)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            for sub in self.subscribers {
                sub.cancel()
            }
            if configurations.count > 1 {
                // TODO: Handle this
            }
            
            if let config = configurations.first {
                #if targetEnvironment(simulator)
                  // Simulator!
                #else
                self.arView.session.run(config, options: .resetTracking)
                #endif
            }
             
            for anchor in anchors {
                self.arView.scene.addAnchor(anchor)
            }

            self.hideTutorialView()
            
        }
    }
    
    private func fetchAllActiveMediaURLs(media: [RealityMedia], completion: @escaping (Result<[URL]>) -> Void) {
        print(media.count)
        let group = DispatchGroup()
        var urls: [URL] = []
        for m in media {
            group.enter()
            self.realityViewModel.fetchRealityFileUrl(from: m) { (result) in
                switch result {
                case .success(let url):
                    urls.append(url)
                    group.leave()
                case .failure(let error):
                    completion(.failure(error))
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(Result.success(urls))
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupViews() {
        self.view.addSubview(arView)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: self.view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        self.view.addSubview(tutorialView)
        NSLayoutConstraint.activate([
            tutorialView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tutorialView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tutorialView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tutorialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
        
        private func addEntityToAnchor(url: URL?, completion: @escaping (_ config: ARConfiguration?, _ anchor: AnchorEntity?, _ error: AppearError?) -> Void) {
        if let url = url {
            DispatchQueue.main.async {
                let loadRequest = Entity.loadAnchorAsync(contentsOf: url)
                loadRequest.sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    }, receiveValue: { anchor in
                        #if targetEnvironment(simulator)
                          // Simulator!
                        #else
                        switch anchor.anchoring.target {
                        case .plane(let alignment, classification: _, minimumBounds: _):
                            let config = ARWorldTrackingConfiguration()
                            config.planeDetection = alignment == .horizontal ? .horizontal : .vertical
                            config.environmentTexturing = .automatic
                            config.isLightEstimationEnabled = true
                            if self.isPeopleOcclusionEnabled {
                                config.frameSemantics.insert(.personSegmentationWithDepth)
                            }
                            if self.isOcclusionFloorEnabled {
                                let floor = MeshResource.generatePlane(width: 2, depth: 2)
                                let material = OcclusionMaterial()
                                let entity = ModelEntity(mesh: floor, materials: [material])
                                anchor.addChild(entity)
                            }
                            completion(config, anchor, nil)
                        case .image(group: _, name: _):
                           let config = ARImageTrackingConfiguration()
                           config.isAutoFocusEnabled = true
                           config.maximumNumberOfTrackedImages = .max
                           completion(config, anchor, nil)
                        case .face:
                            let config = ARFaceTrackingConfiguration()
                            config.maximumNumberOfTrackedFaces = .max
                            config.isLightEstimationEnabled = true
                            completion(config, anchor, nil)
                        default:
                            let config = ARWorldTrackingConfiguration()
                            config.environmentTexturing = .automatic
                            config.isLightEstimationEnabled = true
                            if self.isPeopleOcclusionEnabled {
                                config.frameSemantics.insert(.personSegmentationWithDepth)
                            }
                            completion(config, anchor, nil)
                        }
                        #endif
                    }).store(in: &self.subscribers)
                }
            } else {
                completion(nil, nil, AppearError.unableToCreateModelFromURL)
            }
        
    }
    
    private func hideTutorialView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.tutorialView.alpha = 0
        }, completion: { (_) in
            self.tutorialView.isHidden = true
        })
    }

}

@available(iOS 13.0, *)
extension RealityProjectViewController: AppearManagerNotificationDelegate {
    public func didReceiveActionNotification(withIdentifier identifier: String, entity: Entity?) {
        actionHandler?(identifier, entity)
    }
}
