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
    func fetchRealityProject(completion: @escaping (Result<RealityProject>) -> Void)
    func fetchMedia(withID id: String, completion: @escaping (Result<RealityMedia>) -> Void)
    func fetchRealityFileArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void)
    
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
    
    //MARK:- Reality project type
    public func fetchRealityProject (completion: @escaping (Result<RealityProject>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                AppearLogger().debugPrint("Successfully fetched project data")
                AppearLogger().debugPrint(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                guard let project = try? decoder.decode(RealityProject.self, from: data) else {
                    AppearLogger().fatalErrorPrint("Unable to decode project data to RealityProject struct")
                }
                AppearLogger().debugPrint("Successfully decoded project data to AppearProject")
                completion(Result.success(project))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchMedia(withID id: String, completion: @escaping (Result<RealityMedia>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.mediaWithID(id)) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                AppearLogger().debugPrint("Successfully fetched media data")
                AppearLogger().debugPrint(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                guard let media = try? decoder.decode(RealityMedia.self, from: data) else {
                    AppearLogger().fatalErrorPrint("Unable to decode media data to RealityMedia struct")
                }
                AppearLogger().debugPrint("Successfully decoded project data to AppearProject")
                completion(Result.success(media))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchRealityFileArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: media.url) else { fatalError() }
        AppearLogger().debugPrint("Fetching augmented media data with id \(media.id) from URL: \(url.absoluteString)")
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                AppearLogger().debugPrint("Successfully fetched augmented media with id \(media.id)")
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else {
                    AppearLogger().fatalErrorPrint("\(url.pathExtension.lowercased()) is not a supported file type for media")
                }
                let archiveUrl = self.store(data: data, fileName: media.id, fileType: fileType)
                completion(Result.success(archiveUrl))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    //MARK:- Trigger project type
    public func fetchProject(completion: @escaping (Result<AppearProject>) -> Void) {
        AppearLogger().debugPrint("Fetching project...")
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                AppearLogger().debugPrint("Successfully fetched project data")
                AppearLogger().debugPrint(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                guard let project = try? decoder.decode(AppearProject.self, from: data) else {
                    AppearLogger().fatalErrorPrint("Unable to decode project data to AppearProject struct")
                }
                AppearLogger().debugPrint("Successfully decoded project data to AppearProject")
                completion(Result.success(project))
            case .failure(let error):
                completion(Result.failure(AppearError.errorWithMessage(error.localizedDescription)))
            }
        }
    }
    
    public func fetchTriggerArchiveUrl(from item: AppearProjectItem, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: item.trigger.url) else { fatalError() }
        AppearLogger().debugPrint("Fetching trigger data with name \(item.name) from URL: \(url.absoluteString)")
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                AppearLogger().debugPrint("Successfully fetched trigger with name \(item.name)")
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else {
                     AppearLogger().fatalErrorPrint("\(url.pathExtension.lowercased()) is not a supported file type for trigger")
                }
                let archiveUrl = self.store(data: data, fileName: item.name, fileType: fileType)
                completion(Result.success(archiveUrl))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchMediaArchiveUrl(from media: MediaProtocol, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: media.url) else { fatalError() }
        AppearLogger().debugPrint("Fetching augmented media data with name \(media.name) from URL: \(url.absoluteString)")
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                AppearLogger().debugPrint("Successfully fetched augmented media with name \(media.name)")
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else {
                    AppearLogger().fatalErrorPrint("\(url.pathExtension.lowercased()) is not a supported file type for media")
                }
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
        do {
            try data.write(to: targetURL)
        } catch let error {
            NSLog("Unable to copy file: \(error)")
            fatalError()
        }
        return targetURL
    }
}
