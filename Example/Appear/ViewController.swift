//
//  ViewController.swift
//  Appear
//
//  Created by magnustviberg on 05/01/2019.
//  Copyright (c) 2019 magnustviberg. All rights reserved.
//

import UIKit
import Appear

@available(iOS 13.0, *)
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //present(TriggerARViewController(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       let manager = AppearManager()
        manager.fetchMedia(withID: "c7dc2f20-2330-4b59-b5c2-379d55a860a7") { (result) in
            switch result {
            case .success(let media):
                manager.fetchRealityFileArchiveUrl(from: media) { (result) in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            let vc = RealityFileViewController()
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
