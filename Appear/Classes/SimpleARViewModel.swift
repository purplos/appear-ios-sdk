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
    
    var triggers: [(AppearProjectItem, URL)] = []
    
    func fetchProject(completion: @escaping (Result<AppearProject>) -> Void) {
        manager.fetchProject { (result) in
            completion(result)
        }
    }
    
    func fetchTriggerArchiveUrl(from item: AppearProjectItem, completion: @escaping (Result<URL>) -> Void) {
        // Check memory cache
        if let trigger = triggers.first(where: {$0.0.id == item.id}) {
            completion(Result.success(trigger.1))
        }
        // TODO: chech disk cache
        
        // trigger isnt stored in cache, fetch from server
        manager.fetchTriggerArchiveUrl(from: item) { (result) in
            switch result {
            case .success(let url):
                self.triggers.append((item, url))
                completion(Result.success(url))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    func fetchMediaUrl(from media: MediaProtocol, completion: @escaping (Result<URL>) -> Void) {
        manager.fetchMediaArchiveUrl(from: media, completion: { (result) in
            completion(result)
        })
    }
    
}
