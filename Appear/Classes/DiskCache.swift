//
//  DiskCache.swift
//  Appear
//
//  Created by Magnus Tviberg on 30/11/2019.
//

import Foundation

class DiskCache: Cache {

    private let cacheDirectory = { () -> URL in
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("No document directory found")
        }
        return dir.appendingPathComponent("Cache")
    }()

    private func fileURL<C: Codable>(for type: C.Type, andKey key: String) -> URL {
        let filePath = "\(C.self)-\(key).json"
        return cacheDirectory.appendingPathComponent(filePath)
    }

    public func put<C: Codable>(_ cachable: C, withKey key: String, expires expiration: CacheExpiration = .never) throws {
        let cacheObject = CacheObject(cachable: cachable, expirationDate: expiration.expirationDate)
        let data = try JSONEncoder().encode(cacheObject)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        try data.write(to: fileURL(for: C.self, andKey: key))
    }

    public func get<C: Codable>(_ type: C.Type, forKey key: String) -> C? {
        guard let data = try? Data(contentsOf: fileURL(for: C.self, andKey: key)),
            let cacheObject = try? JSONDecoder().decode(CacheObject<C>.self, from: data) else { return nil }

        guard let expirationDate = cacheObject.expirationDate else {
            return cacheObject.cachable
        }

        if Date() > expirationDate {
            try? remove(type, forKey: key)
            debugPrint("DiskCache: Object \(C.self) with key \(key) expired at \(expirationDate).")
            return nil
        }

        return cacheObject.cachable
    }

    public func has<C: Codable>(_ type: C.Type, forKey key: String) -> Bool {
        return get(type, forKey: key) != nil
    }

    public func remove<C: Codable>(_ type: C.Type, forKey key: String) throws {
        try FileManager.default.removeItem(at: fileURL(for: type, andKey: key))
    }

    public func clear() throws {
        try FileManager.default.removeItem(at: cacheDirectory)
    }

    struct CacheObject<C: Codable>: Codable {
        let cachable: C
        let expirationDate: Date?
    }
}
