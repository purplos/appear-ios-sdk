//
//  AppearManager.swift
//  Appear
//
//  Created by Magnus Tviberg on 11/06/2019.
//

import Foundation
import CoreLocation
import ARKit
import RealityKit

public protocol AppearManagerNotificationDelegate {
    @available(iOS 13.0, *)
    func didReceiveActionNotification(withIdentifier identifier: String, entity: RealityKit.Entity?)
}

public class AppearManager {
    
    let cache: DiskCache = DiskCache()
    
    public var delegate: AppearManagerNotificationDelegate?
    
    @available(iOS 13.0, *)
    func sendAction(withIdentifier identifier: String, entity: Entity?) {
        let notificationTrigger = NotificationTrigger(identifier: identifier, root: entity)
        notificationTrigger.post()
    }
    
    //MARK:- Receive notification
    @available(iOS 13.0, *)
    func setupActionListener() {
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
    
    //MARK:- Send notification
    @available(iOS 13.0, *)
    private class NotificationTrigger {

        public let identifier: Swift.String

        private weak var root: RealityKit.Entity?

        fileprivate init(identifier: Swift.String, root: RealityKit.Entity?) {
            self.identifier = identifier
            self.root = root
        }

        public func post(overrides: [Swift.String: RealityKit.Entity]? = nil) {
            guard let scene = root?.scene else {
                AppearLogger().errorPrint("Unable to post notification trigger with identifier \"\(self.identifier)\" because the root is not part of a scene")
                return
            }

            var userInfo: [Swift.String: Any] = [
                "RealityKit.NotificationTrigger.Scene": scene,
                "RealityKit.NotificationTrigger.Identifier": self.identifier
            ]
            userInfo["RealityKit.NotificationTrigger.Overrides"] = overrides

            Foundation.NotificationCenter.default.post(name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotificationTrigger"), object: self, userInfo: userInfo)
        }

    }
    
    deinit {
        Foundation.NotificationCenter.default.removeObserver(self, name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
    }
    
}

    //MARK:- AppearManagerProtocol implementation
extension AppearManager: AppearManagerProtocol {
    public func fetchRealityProject (completion: @escaping (Result<RealityProject>) -> Void) {
        guard AppearApp.isConfigured else { AppearLogger().fatalErrorPrint(AppearError.missingConfiguration.errorMessage)}
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                AppearLogger().debugPrint("Successfully fetched project data")
                AppearLogger().debugPrint(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                do {
                    let project = try decoder.decode(RealityProject.self, from: data)
                    AppearLogger().debugPrint("Successfully decoded project data to AppearProject")
                    completion(Result.success(project))
                } catch {
                    self.handle(fatalError: AppearError.unableToDecode(.project))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchMedia(withID id: String, completion: @escaping (Result<RealityMedia>) -> Void) {
        guard AppearApp.isConfigured else { AppearLogger().fatalErrorPrint(AppearError.missingConfiguration.errorMessage)}
        WebService.sharedInstance.request(AppearEndpoint.mediaWithID(id)) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                AppearLogger().debugPrint("Successfully fetched media data")
                AppearLogger().debugPrint(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                
                do {
                    let media = try decoder.decode(RealityMedia.self, from: data)
                    AppearLogger().debugPrint("Successfully decoded data to RealityMedia")
                    completion(Result.success(media))
                }catch {
                    self.handle(fatalError: AppearError.unableToDecode(.project))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    public func fetchRealityFileArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void) {
        guard AppearApp.isConfigured else { AppearLogger().fatalErrorPrint(AppearError.missingConfiguration.errorMessage)}
        guard let url = URL(string: media.url) else { fatalError() }
        AppearLogger().debugPrint("Fetching augmented media data with id \(media.id) from URL: \(url.absoluteString)")
        
        if let options = AppearApp.debugOptions,
            !options.contains(.disableCaching),
            cache.has(forKey: media.id) {
            AppearLogger().debugPrint("Media data with id \(media.id) found in cache")
            completion(Result.success(cache.fileURLs(forKey: media.id, fileType: .reality)[1]))
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
    
    //MARK:- Cache
    private func store(data: Data, fileName: String, fileType: SupportedFileType, completion: @escaping (Result<URL>) -> Void) {
        do {
            let isCachingDisabled = AppearApp.debugOptions?.contains(.disableCaching) ?? false
            let url = try cache.put(data, withKey: fileName, fileType: fileType, expires: isCachingDisabled ? .in(.seconds(0)) : .in(.minutes(60)))
            completion(Result.success(url))
        } catch (let error) {
            completion(Result.failure(error))
        }
    }
    
    private func handle(fatalError: Error) {
        if let appearError = fatalError as? AppearError {
            AppearLogger().fatalErrorPrint(appearError.errorMessage)
        } else {
            AppearLogger().fatalErrorPrint(fatalError.localizedDescription)
        }
    }
}
