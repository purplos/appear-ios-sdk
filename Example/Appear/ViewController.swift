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
        let vc = RealityFileViewController()
        vc.configure(withIdentifier: "96329fe1-8955-4ca1-930d-3e290bede6e7")
        present(vc, animated: true, completion: nil)
    }
    
}
