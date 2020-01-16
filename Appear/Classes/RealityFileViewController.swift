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
    
    let realityViewModel = RealityFileViewModel()
    var cancellable: AnyCancellable?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(anchor)
        
        realityViewModel.fetchProject { (result) in
            switch result {
            case .success(let project):
                guard let media = project.media.first else {
                    AppearLogger().fatalErrorPrint("No media")
                }
                self.realityViewModel.fetchRealityFileUrl(from: media) { [weak self] (result) in
                    switch result {
                    case .success(let url):
                        print("successful fetch")
                        self?.addEntityToAnchor(url: url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
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
        
    func addEntityToAnchor(url: URL?) {
        print("adding entity")
        print(url)
        DispatchQueue.main.async {
            self.cancellable = Entity.loadAnchorAsync(contentsOf: url!)
            .sink(receiveCompletion: { loadCompletion in
                print("---------- error")
                self.cancellable?.cancel()
            }, receiveValue: { (entity) in
                print("---------- loaded")
                self.arView.scene.addAnchor(entity)
                self.cancellable?.cancel()
                self.hideTutorialView()
            })
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
