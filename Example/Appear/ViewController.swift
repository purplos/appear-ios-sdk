//
//  ViewController.swift
//  Appear
//
//  Created by magnustviberg on 05/01/2019.
//  Copyright (c) 2019 magnustviberg. All rights reserved.
//

import UIKit
import Appear

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let simpleVC = SimpleARViewController()
        present(simpleVC, animated: true, completion: nil)
    }

}

