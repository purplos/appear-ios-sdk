//
//  RealityFileViewController.swift
//  Appear
//
//  Created by Magnus Tviberg on 04/12/2019.
//

import UIKit
import RealityKit

@available(iOS 13.0, *)
class RealityFileViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(anchor)
        
        let name = "AdobeAero2"
        let url = Bundle.main.url(forResource: name, withExtension: "reality")
        do {
            let entity = try Entity.load(contentsOf: url!)
            //self.installGestures(.all, for: greenBox)
            anchor.addChild(entity)
        } catch(let error) {
            print(error.localizedDescription)
        }
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
    
    private func hideTutorialView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.tutorialView.alpha = 0
        }, completion: { (_) in
            self.tutorialView.isHidden = true
        })
    }

}
