//
//  ViewController.swift
//  Appear
//
//  Created by magnustviberg on 05/01/2019.
//  Copyright (c) 2019 magnustviberg. All rights reserved.
//

import UIKit
import ARKit
import Appear

class ViewController: UIViewController {
    
    let triggerVC = TriggerARViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //present(TriggerARViewController(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       present(triggerVC, animated: true, completion: nil)
    }

}
