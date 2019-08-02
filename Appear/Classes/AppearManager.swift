//
//  NewAppearManager.swift
//  Appear
//
//  Created by Magnus Tviberg on 11/06/2019.
//

import Foundation
import CoreLocation
import ARKit

public protocol AppearManagerProtocol {
    func fetchProject(completion: @escaping (Result<AppearProject>) -> Void)
    func fetchTriggerArchiveUrl(from item: AppearProjectItem, completion: @escaping (Result<URL>) -> Void)
    func fetchMediaArchiveUrl(from media: MediaProtocol, completion: @escaping (Result<URL>) -> Void)
}

public class AppearManager {
    
    public init() {
        guard AppearApp.isConfigured else { fatalError(AppearError.missingConfiguration.errorMessage)}
    }
    
}

extension AppearManager: AppearManagerProtocol {
    public func fetchProject(completion: @escaping (Result<AppearProject>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                print(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                guard let project = try? decoder.decode(AppearProject.self, from: data) else { fatalError() }
                completion(Result.success(project))
            case .failure(let error):
                completion(Result.failure(AppearError.errorWithMessage(error.localizedDescription)))
            }
        }
    }
    
    public func fetchTriggerArchiveUrl(from item: AppearProjectItem, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: item.trigger.url) else { fatalError() }
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else { fatalError() }
                let archiveUrl = self.store(data: data, fileName: item.name, fileType: fileType)
                completion(Result.success(archiveUrl))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchMediaArchiveUrl(from media: MediaProtocol, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: media.url) else { fatalError() }
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else { fatalError() }
                let archiveUrl = self.store(data: data, fileName: media.name, fileType: fileType)
                completion(Result.success(archiveUrl))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    // MARK: Private functions
    
    private func fetchData(from url: URL, completion: @escaping (Result<Data>) -> Void) {
        
        let session = URLSession(configuration: .default)
        let downloadTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(Result.failure(error))
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Fetched data with response code \(res.statusCode)")
                    if let data = data {
                        completion(Result.success(data))
                    } else {
                        completion(Result.failure(HTTPResponseError.responseErrorWith(message: "ERROR: No data")))
                    }
                } else {
                    completion(Result.failure(HTTPResponseError.responseErrorWith(message: "ERROR: Couldn't get response code for some reason")))
                }
            }
        }
        
        downloadTask.resume()
    }
    
    private func store(data: Data, fileName: String, fileType: SupportedFileType) -> URL {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("\(fileName).\(fileType)")
        print(targetURL)
        do {
            try data.write(to: targetURL)
        } catch let error {
            NSLog("Unable to copy file: \(error)")
            fatalError()
        }
        return targetURL
    }
    
}
