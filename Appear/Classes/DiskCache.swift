//
//  DiskCache.swift
//  Appear
//
//  Created by Magnus Tviberg on 30/11/2019.
//

import Foundation

class DiskCache {

    private let cacheDirectory = { () -> URL in
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("No document directory found")
        }
        return dir.appendingPathComponent("Cache")
    }()

    func fileURLs(forKey key: String, fileType: SupportedFileType) -> [URL] {
        let jsonPath = "\(key).json"
        let dataPath = "\(key).\(fileType)"
        let jsonURL = cacheDirectory.appendingPathComponent(jsonPath)
        let dataURL = cacheDirectory.appendingPathComponent(dataPath)
        return [jsonURL, dataURL]
    }

    func put(_ data: Data, withKey key: String, fileType: SupportedFileType, expires expiration: CacheExpiration = .never) throws -> URL {
        let cacheObject = CacheObject(url: fileURLs(forKey: key, fileType: fileType)[1], expirationDate: expiration.expirationDate)
        let cacheObjectJSON = try JSONEncoder().encode(cacheObject)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        try cacheObjectJSON.write(to: fileURLs(forKey: key, fileType: fileType)[0])
        try data.write(to: fileURLs(forKey: key, fileType: fileType)[1])
        AppearLogger().debugPrint("Object with key \(key) stored in cache. Expires at \(String(describing: expiration.expirationDate)).")
        return fileURLs(forKey: key, fileType: fileType)[1]
    }
    
    func get(forKey key: String) -> Data? {
        guard let data = try? Data(contentsOf: fileURLs(forKey: key, fileType: .reality)[1]),
            let cacheObjectData = try? Data(contentsOf: fileURLs(forKey: key, fileType: .reality)[0]),
            let cacheObject = try? JSONDecoder().decode(CacheObject.self, from: cacheObjectData) else { return nil }

        guard let expirationDate = cacheObject.expirationDate else {
            return data
        }

        if Date() > expirationDate {
            try? remove(forKey: key)
            AppearLogger().debugPrint("Removed Object with key \(key) from cache. Reason: Expired at \(expirationDate).")
            return nil
        }
        
        return data
    }

    func has(forKey key: String) -> Bool {
        return get(forKey: key) != nil
    }

    func remove(forKey key: String) throws {
        try FileManager.default.removeItem(at: fileURLs(forKey: key, fileType: .reality)[0])
        try FileManager.default.removeItem(at: fileURLs(forKey: key, fileType: .reality)[1])
    }

    func clear() throws {
        try FileManager.default.removeItem(at: cacheDirectory)
    }

    struct CacheObject: Codable {
        let url: URL
        let expirationDate: Date?
    }
}

enum CacheExpiration {
    case `in`(TimePeriod)
    case at(date: Date)
    case never

    var expirationDate: Date? {
        switch self {
        case .`in`(let timePeriod):
            return Date(timeInterval: timePeriod.timeInterval, since: Date())
        case .at(let date):
            return date
        case .never:
            return nil
        }
    }

    var timestamp: TimeInterval? {
        return expirationDate?.timeIntervalSince1970
    }

    enum TimePeriod {
        case seconds(Int)
        case minutes(Int)
        case hours(Int)
        case days(Int)
        case months(Int)

        var timeInterval: TimeInterval {
            switch self {
            case .seconds(let n):
                return TimeInterval(n)
            case .minutes(let n):
                return TimePeriod.seconds(n * 60).timeInterval
            case .hours(let n):
                return TimePeriod.minutes(n * 60).timeInterval
            case .days(let n):
                return TimePeriod.hours(n * 24).timeInterval
            case .months(let n):
                return TimePeriod.days(n * 31).timeInterval
            }
        }
    }
}
