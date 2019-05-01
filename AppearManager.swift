//
//  AppearManager.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation
import CoreLocation
import ARKit

public struct AppearProjectWithMedia {
    var items: [AppearProjectWithMediaItem]
}

public struct AppearProjectWithMediaItem {
    var name: String
    var type: MediaType
    var image: AppearProjectReferenceImage
    var media: PresentableMedia
}

public struct AppearProjectReferenceImage {
    var width: Float32
    var data: Data
}

public struct PresentableMedia {
    var localURL: URL
}

public protocol AppearManagerProtocol {
    func fetchProject(completion: @escaping (Result<AppearProjectWithMedia>) -> Void)
    //func fetchCampaignInfo(completion: @escaping (Result<ModelCampaign>) -> Void)
    func fetchTrackingImage(from url: URL, completion: @escaping (Data?, Error?) -> Void)
    func fetchARContent(from campaign: AppearProject, completion: @escaping (Result<AppearProjectWithMedia>) -> Void)
    //func fetchModel(from url: URL, completion: @escaping (URL?, Error?) -> Void)
}

public class AppearManager: AppearManagerProtocol {
    
    public init() {
        guard AppearApp.isConfigured else { fatalError(AppearError.missingConfiguration.errorMessage)}
    }
    
    public func fetchCampaign(completion: @escaping (Result<AppearProject>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                guard let campaign = try? decoder.decode(AppearProject.self, from: data) else { fatalError() }
                completion(Result.success(campaign))
                
            case .failure(let error):
                completion(Result.failure(AppearError.errorWithMessage(error.localizedDescription)))
            }
        }
    }
    
    public func fetchProject(completion: @escaping (Result<AppearProjectWithMedia>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.getProject) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                print(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                
                guard let campaign = try? decoder.decode(AppearProject.self, from: data) else { fatalError() }
                self.fetchARContent(from: campaign, completion: { (result) in
                    completion(result)
                })
                
            case .failure(let error):
                completion(Result.failure(AppearError.errorWithMessage(error.localizedDescription)))
            }
        }
    }
    
    public func fetchNearbyProjects(latitude: Double, longitude: Double, completion: @escaping (Result<[AppearProject]>) -> Void) {
        WebService.sharedInstance.request(AppearEndpoint.getNearbyProjects(lat: latitude, lon: longitude)) { (result: Result<Data>) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                print(String(data: data, encoding: String.Encoding.utf8) ?? "kunne ikke printe json")
                
                guard let campaigns = try? decoder.decode([AppearProject].self, from: data) else { fatalError() }
                
                print(campaigns)
                
            case .failure(let error):
                completion(Result.failure(AppearError.errorWithMessage(error.localizedDescription)))
            }
        }
    }
    
    private func fetchRefrenceImages(from project: AppearProject, completion: @escaping (Result<[AppearProjectReferenceImage]>) -> Void) {
        var fetchedPresentableTrackingImages: [AppearProjectReferenceImage] = []
        var fetchedCampaignErrors: [Error] = []
        
        let outerGroup = DispatchGroup()
        
        for object in project.items {
            outerGroup.enter()
            
            self.fetchTrackingImage(from: object.image.url, completion: { (imageData, error) in
                if error != nil {
                    fetchedCampaignErrors.append(error!)
                } else {
                    guard let data = imageData else {
                        fetchedCampaignErrors.append(AppearError.errorWithMessage("no image data"))
                        outerGroup.leave()
                        return
                    }
                    fetchedPresentableTrackingImages.append(AppearProjectReferenceImage(width: object.image.width / 100, data: data))
                }
                outerGroup.leave()
            })
        }
        
        outerGroup.notify(queue: DispatchQueue.main) {
            if fetchedCampaignErrors.isEmpty == false {
                completion(Result.failure(fetchedCampaignErrors.first!))
            } else if fetchedPresentableTrackingImages.isEmpty == false {
                completion(Result.success(fetchedPresentableTrackingImages))
            } else {
                fatalError()
            }
        }
    }
    
    public func fetchARContent(from campaign: AppearProject, completion: @escaping (Result<AppearProjectWithMedia>) -> Void) {
        var fetchedPresentableObjects: [AppearProjectWithMediaItem] = []
        var fetchedCampaignErrors: [Error] = []
        
        let outerGroup = DispatchGroup()
        
        for object in campaign.items {
            outerGroup.enter()
            
            var fetchImageError: Error?
            var fetchedImageData: Data?
            var fetchedMediaError: Error?
            var fetchedMediaURL: URL?
            
            let innerGroup = DispatchGroup()
            
            innerGroup.enter()
            self.fetchTrackingImage(from: object.image.url, completion: { (imageData, error) in
                fetchImageError = error
                fetchedImageData = imageData
                innerGroup.leave()
            })
            
            innerGroup.enter()
            self.fetchMediaAndStoreLocally(from: object, completion: { (mediaURL, error) in
                fetchedMediaError = error
                print("fetchedMediaURL = mediaURL = \(String(describing: mediaURL))")
                fetchedMediaURL = mediaURL
                innerGroup.leave()
            })
            
            innerGroup.notify(queue: DispatchQueue.main) {
                if let imageError = fetchImageError {
                    fetchedCampaignErrors.append(imageError)
                    outerGroup.leave()
                } else if let mediaError = fetchedMediaError {
                    fetchedCampaignErrors.append(mediaError)
                    outerGroup.leave()
                } else if let imageData = fetchedImageData, let mediaURL = fetchedMediaURL {
                    fetchedPresentableObjects.append(AppearProjectWithMediaItem(name: object.name, type: object.type, image: AppearProjectReferenceImage(width: object.image.width / 100, data: imageData), media: PresentableMedia(localURL: mediaURL)))
                    outerGroup.leave()
                } else {
                    fatalError()
                }
            }
        }
        outerGroup.notify(queue: DispatchQueue.main) {
            if fetchedCampaignErrors.isEmpty == false {
                completion(Result.failure(fetchedCampaignErrors.first!))
            } else if fetchedPresentableObjects.isEmpty == false {
                completion(Result.success(AppearProjectWithMedia(items: fetchedPresentableObjects)))
            } else {
                fatalError()
            }
        }
    }
    
    /*
     
     public func fetchCampaignInfo(completion: @escaping (Result<ModelCampaign>) -> Void) {
     WebService.sharedInstance.request(CampaignEndpoint.getCampaign) { (result: Result<Data>) in
     switch result {
     case .success(let data):
     let decoder = JSONDecoder()
     decoder.dateDecodingStrategy = .secondsSince1970
     do {
     let campaignInfo = try decoder.decode(ModelCampaign.self, from: data)
     completion(Result.success(campaignInfo))
     }
     catch {
     completion(Result.failure(HTTPResponseError.cannotParse))
     }
     case .failure(let error):
     completion(Result.failure(error))
     }
     }
     }*/
    
    func fetchTrackingImage(from urlString: String?, completion: @escaping (Data?, Error?) -> Void) {
        guard let urlString = urlString else { fatalError() }
        let newString = urlString.replacingOccurrences(of: "http://localhost:8000", with: "http://e8e979d2.ngrok.io")
        
        guard let url = URL(string: newString) else {
            completion(nil, HTTPResponseError.responseErrorWith(message: "ERROR: Could not make URL from urlString"))
            return
        }
        
        fetchTrackingImage(from: url) { (data, error) in
            completion(data, error)
        }
    }
    
    public func fetchTrackingImage(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        completion(imageData, nil)
                    } else {
                        completion(nil, HTTPResponseError.responseErrorWith(message: "ERROR: No data"))
                    }
                } else {
                    completion(nil, HTTPResponseError.responseErrorWith(message: "ERROR: Couldn't get response code for some reason"))
                }
            }
        }
        
        downloadPicTask.resume()
    }
    
    func fetchMediaAndStoreLocally(from campaign: AppearProjectItem, completion: @escaping (URL?, Error?) -> Void) {
        fetchMedia(from: campaign) { (url, error) in
            completion(url, error)
        }
    }
    
    /*
     
     func fetchMedia(from urlString: String?, completion: @escaping (URL?, Error?) -> Void) {
     guard let urlString = urlString else {
     fatalError()
     }
     
     let newString = urlString.replacingOccurrences(of: "http://localhost:8000", with: "http://e8e979d2.ngrok.io")
     
     guard let url = URL(string: newString) else {
     completion(nil, HTTPResponseError.responseErrorWith(message: "ERROR: Could not make URL from urlString"))
     return
     }
     fetchMedia(from: url) { (url, error) in
     completion(url, error)
     }
     }*/
    
    
    public func fetchMedia(from campaign: AppearProjectItem, completion: @escaping (URL?, Error?) -> Void) {
        
        guard let url = URL(string: campaign.media.url) else {
            completion (nil, AppearError.errorWithMessage("no media url"))
            return
        }
        
        print(url)
        
        let mediaTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                guard let error = error else {
                    completion(nil, AppearError.errorWithMessage("No data"))
                    return
                }
                completion(nil, AppearError.errorWithMessage(error.localizedDescription))
                return
            }
            
            switch campaign.type {
            case .model:
                let url = self.store(data: dataResponse, for: campaign)
                completion(url, nil)
                return
                /*do {
                 let unzipDirectory = try Zip.quickUnzipFile(url) // Unzip
                 let fileManager = FileManager()
                 let enumerator = fileManager.enumerator(at: unzipDirectory, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey])
                 guard let emr = enumerator else {
                 completion(nil, ARCampaignError.unzipFromURLFailed)
                 return
                 }
                 
                 guard let filePaths = emr.allObjects as? [URL] else {
                 completion(nil, ARCampaignError.unzipFromURLFailed)
                 return
                 }
                 let scnFiles = filePaths.filter{URL(fileURLWithPath: $0.absoluteString, relativeTo: unzipDirectory).path.hasSuffix(".scn")}
                 guard let scnFile = scnFiles.first else {
                 completion(nil, ARCampaignError.unzipFromURLFailed)
                 return
                 }
                 completion(scnFile, nil)
                 return
                 } catch (let error) {
                 print(error.localizedDescription)
                 completion(nil, ARCampaignError.unzipFromURLFailed)
                 return
                 }*/
            case .video:
                let url = self.store(data: dataResponse, for: campaign)
                completion(url, nil)
                return
            }
        }
        mediaTask.resume()
    }
    
    private func store(data: Data, for campaignObject: AppearProjectItem) -> URL {
        
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL: URL
        switch campaignObject.type {
        case .model:
            targetURL = tempDirectoryURL.appendingPathComponent("\(campaignObject.name).scn")
        case .video:
            targetURL = tempDirectoryURL.appendingPathComponent("\(campaignObject.name).MP4")
        }
        print(targetURL)
        do {
            try data.write(to: targetURL)
        } catch let error {
            NSLog("Unable to copy file: \(error)")
        }
        
        return targetURL
    }
    
}


var testJSON = """
        [{
        "type": "private",
        "id": "flksdjf213",
        "items": [{
                "type": "video",
                "name": "test1",
                "image": {
                    "width": 0.13,
                    "url": "https://i.imgur.com/u2VrRJF.jpg",
                    "found_locations": [{
                        "latitude": 59.2463957,
                        "longitude": 10.347494
                    }]
                },
                "media": {
                    "url": "https://hqwallpaper.ams3.cdn.digitaloceanspaces.com/A4AD374C-7840-4E01-AC07-7F9BB182584E.MP4"
                }
            },
            {
                "type": "model",
                "name": "test2",
                "image": {
                    "width": 0.13,
                    "url": "https://i.imgur.com/ekRmTH4.jpg"
                },
                "media": {
                    "url": "https://hqwallpaper.ams3.cdn.digitaloceanspaces.com/trophy.zip"
                }
            }
        ]
    }]
 """.data(using: .utf8)!

