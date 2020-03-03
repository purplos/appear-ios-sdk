//
//  RealityFileViewController.swift
//  Appear
//
//  Created by Magnus Tviberg on 04/12/2019.
//

import UIKit
import RealityKit
import Combine

@available(iOS 13.0, *)
public class RealityFileViewController: UIViewController {

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
    
    private var actionHandler: ((String, RealityKit.Entity?) -> Void)?
    private var urls: [URL]?
    private let realityViewModel = RealityFileViewModel()
    private var subscribers = Set<AnyCancellable>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let urls = urls {
            self.loadAnchors(from: urls)
        } else {
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
    }
    
    public func configure(withURLs urls: [URL]) {
        self.urls = urls
    }
    
    private func loadAnchors(from urls: [URL]) {
        let group = DispatchGroup()
        for url in urls {
            group.enter()
            self.addEntityToAnchor(url: url) {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            for sub in self.subscribers {
                sub.cancel()
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
        
    private func addEntityToAnchor(url: URL?, completion: @escaping () -> Void) {
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
                        print("receiveValue")
                        self.setupNotificationListener()
                        self.arView.scene.addAnchor(anchor)
                        completion()
                    }).store(in: &self.subscribers)
                }
            } else {
                fatalError("no url")
            }
    }
    
    private func hideTutorialView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.tutorialView.alpha = 0
        }, completion: { (_) in
            self.tutorialView.isHidden = true
        })
    }
    
    private func setupNotificationListener() {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(actionDidFire(notification:)), name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
    }
    
    @objc
    private func actionDidFire(notification: Foundation.Notification) {

        guard let userInfo = notification.userInfo as? [Swift.String: Any] else {
            return
        }

        guard let identifier = userInfo["RealityKit.NotifyAction.Identifier"] as? Swift.String else {
                return
        }

        let entity = userInfo["RealityKit.NotifyAction.Entity"] as? RealityKit.Entity

        onAction(identifier, entity)
    }
    
    private func onAction(_ identifier: String, _ entity: Entity?) {
        guard let handler = actionHandler else {
            return
        }
        handler(identifier, entity)
    }
    
    deinit {
        Foundation.NotificationCenter.default.removeObserver(self, name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
    }


}
