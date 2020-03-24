//
//  NewAppearManager.swift
//  Appear
//
//  Created by Magnus Tviberg on 11/06/2019.
//

import Foundation
import CoreLocation
import ARKit
import RealityKit

public protocol AppearManagerDelegate {
    @available(iOS 13.0, *)
    func didReceiveActionNotification(withIdentifier identifier: String, entity: RealityKit.Entity?)
}

public protocol AppearManagerProtocol {
    func fetchRealityProject(completion: @escaping (Result<RealityProject>) -> Void)
    func fetchMedia(withID id: String, completion: @escaping (Result<RealityMedia>) -> Void)
    func fetchRealityFileArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void)
}

public class AppearManager {
    
    let cache: DiskCache = DiskCache()
    
    public var delegate: AppearManagerDelegate? {
        didSet {
            if #available(iOS 13.0, *) {
                setupActionListener()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public init() {
        guard AppearApp.isConfigured else { fatalError(AppearError.missingConfiguration.errorMessage)}
    }
    
    @available(iOS 13.0, *)
    private func setupActionListener() {
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(actionDidFire(notification:)), name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
    }
    
    @available(iOS 13.0, *)
    @objc
    private func actionDidFire(notification: Foundation.Notification) {

        guard let userInfo = notification.userInfo as? [Swift.String: Any] else {
            return
        }

        guard let identifier = userInfo["RealityKit.NotifyAction.Identifier"] as? Swift.String else {
                return
        }

        let entity = userInfo["RealityKit.NotifyAction.Entity"] as? RealityKit.Entity

        onAction(identifier, entity)
    }
    
    @available(iOS 13.0, *)
    private func onAction(_ identifier: String, _ entity: Entity?) {
        delegate?.didReceiveActionNotification(withIdentifier: identifier, entity: entity)
    }
    
    deinit {
        Foundation.NotificationCenter.default.removeObserver(self, name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
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
        
        if cache.has(Data.self, forKey: media.id) {
            print("returning cached url")
            completion(Result.success(cache.fileURL(forKey: media.id, fileType: .reality)))
        } else {
            self.fetchData(from: url) { (result) in
                switch result {
                case .success(let data):
                    AppearLogger().debugPrint("Successfully fetched augmented media with id \(media.id)")
                    guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else {
                        AppearLogger().fatalErrorPrint("\(url.pathExtension.lowercased()) is not a supported file type for media")
                    }
                    self.store(data: data, fileName: media.id, fileType: fileType, completion: { result in
                        completion(result)
                    })
                case .failure(let error):
                    completion(Result.failure(error))
                }
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
                if response as? HTTPURLResponse != nil {
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
    
    private func store(data: Data, fileName: String, fileType: SupportedFileType, completion: @escaping (Result<URL>) -> Void) {
        do {
            let url = try cache.put(data, withKey: fileName, fileType: fileType, expires: .in(.minutes(15)))
            completion(Result.success(url))
        } catch (let error) {
            completion(Result.failure(error))
        }
        
//        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
//        let targetURL = tempDirectoryURL.appendingPathComponent("\(fileName).\(fileType)")
//        do {
//            try data.write(to: targetURL)
//        } catch let error {
//            NSLog("Unable to copy file: \(error)")
//            fatalError()
//        }
//        return targetURL
    }
}
