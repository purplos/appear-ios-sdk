//
//  AppearProject.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

public struct AppearProject: Decodable {
    public let items: [AppearProjectItem]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
}

extension AppearProject {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decode([AppearProjectItem].self, forKey: .items)
    }
}

public struct AppearProjectItem: Codable {
    public let name: String
    public let image: TrackingImage
    public let type: MediaType
    public let media: Media
}

public enum MediaType: String, Codable {
    case model
    case video
}

public struct TrackingImage: Codable {
    public let width: Float32
    public let url: String
}

public struct Media: Codable {
    public let url: String
}



