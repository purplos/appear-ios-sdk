//
//  ViewController.swift
//  Appear
//
//  Created by magnustviberg on 05/01/2019.
//  Copyright (c) 2019 magnustviberg. All rights reserved.
//

import UIKit
import Appear
import RealityKit

@available(iOS 13.0, *)
class ViewController: UIViewController {
    
    private var manager: AppearManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        //present(TriggerARViewController(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager = AppearManager()
        manager.delegate = self
        manager.fetchMedia(withID: "96329fe1-8955-4ca1-930d-3e290bede6e7") { (result) in
            switch result {
            case .success(let media):
                self.manager.fetchRealityFileArchiveUrl(from: media) { (result) in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            let vc = RealityFileViewController()
//                            vc.onAction { (identifier, entity) in
//                                if identifier == "testtrigger" {
//                                    print("wohooo")
//                                } else {
//                                    print("buhuuuu")
//                                }
//                            }
                            vc.configure(withURLs: [url])
                            self.present(vc, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

@available(iOS 13.0, *)
extension ViewController: AppearManagerDelegate {
    func didReceiveActionNotification(withIdentifier identifier: String, entity: Entity?) {
        print(identifier)
    }
}
