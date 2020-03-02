//
//  RealityManager.swift
//  Appear
//
//  Created by Magnus Tviberg on 05/02/2020.
//

import Foundation

public protocol RealityManager {
    func fetchRealityProject(completion: @escaping (Result<RealityProject>) -> Void)
    func fetchArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void)
}

public class RealityManagerImpl {
    
    public init() {
        guard AppearApp.isConfigured else { fatalError(AppearError.missingConfiguration.errorMessage)}
    }
    
}

extension RealityManagerImpl: RealityManager {
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
    
    public func fetchArchiveUrlFromMedia(with id: String, completion: @escaping (Result<URL>) -> Void) {
        
    }
    
    public func fetchArchiveUrl(from media: RealityMedia, completion: @escaping (Result<URL>) -> Void) {
        guard let url = URL(string: media.url) else { fatalError() }
        AppearLogger().debugPrint("Fetching augmented media data with id \(media.id) from URL: \(url.absoluteString)")
        self.fetchData(from: url) { (result) in
            switch result {
            case .success(let data):
                AppearLogger().debugPrint("Successfully fetched augmented media with id \(media.id)")
                guard let fileType = SupportedFileType.init(rawValue: url.pathExtension.lowercased()) else {
                    AppearLogger().fatalErrorPrint("\(url.pathExtension.lowercased()) is not a supported file type for media")
                }
                print(media)
                let archiveUrl = self.store(data: data, fileName: media.id, fileType: fileType)
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
