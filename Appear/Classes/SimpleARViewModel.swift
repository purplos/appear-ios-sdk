//
//  SimpleARViewModel.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

@available(iOS 12.0, *)
class SimpleARViewModel {
    let manager: AppearManagerProtocol = AppearManager()
    
    func fetchProject(completion: @escaping (Result<AppearProjectWithMedia>) -> Void) {
        manager.fetchProject { (result) in
            completion(result)
        }
    }
    
}
