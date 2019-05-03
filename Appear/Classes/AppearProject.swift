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

public struct AppearProjectItem: Decodable {
    public let type: MediaType
    public let name: String
    public let referenceImage: TrackingImage
    public let media: Media
}

public enum MediaType: String, Decodable {
    case model
    case video
}

public struct TrackingImage: Decodable {
    public let width: Float32
    public let url: String
}
/*
public struct Media: Decodable {
    public let url: String
}*/

public enum Media {
    case video(VideoMedia)
    case model(ModelMedia)
    case unsupported
}

public struct VideoMedia: Decodable {
    public let url: URL
    public let contentMode: ContentMode
}

public struct ModelMedia: Decodable {
    public let url: URL
    public let scale: Float32
}

extension AppearProjectItem {
    private enum CodingKeys: String, CodingKey {
        case type
        case referenceImage
        case name
        case media
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //let media = try container.decode(Media.self, forKey: .media)
        self.name = try container.decode(String.self, forKey: .name)
        self.referenceImage = try container.decode(TrackingImage.self, forKey: .referenceImage)
        self.type = try container.decode(MediaType.self, forKey: .type)
        switch type {
        case .video:
            let media = try container.decode(VideoMedia.self, forKey: .media)
            self.media = .video(media)
        case .model:
            let media = try container.decode(ModelMedia.self, forKey: .media)
            self.media = .model(media)
        }
    }
}

public enum ContentMode: String, Decodable {
    case scaleToFill
    case aspectFit
}

