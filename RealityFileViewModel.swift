//
//  RealityFileViewModel.swift
//  Appear
//
//  Created by Magnus Tviberg on 15/01/2020.
//

import Foundation

@available(iOS 13.0, *)
class RealityFileViewModel {
    let manager: AppearManagerProtocol = AppearManager()
    
    func fetchProject(completion: @escaping (Result<RealityProject>) -> Void) {
        manager.fetchRealityProject { (result) in
            completion(result)
        }
    }
    
    func fetchRealityFileUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void) {
        manager.fetchRealityFileArchiveUrl(from: media) { (result) in
            completion(result)
        }
    }
    
}
