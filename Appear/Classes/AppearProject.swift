//
//  AppearProject.swift
//  Appear
//
//  Created by Magnus Tviberg on 10/06/2019.
//

import Foundation

public protocol MediaProtocol: Decodable {
    var type: AppearProjectItem.MediaType { get }
    var url: String { get }
    var name: String { get }
}

public protocol TriggerProtocol: Decodable {
    var type: AppearProjectItem.TriggerType { get }
    var url: String { get }
}

public struct AppearProject: Decodable {
    public let id: UUID?
    public let type: APIProjectType
    public let name: String
    public let start: Date?
    public let end: Date?
    public var items: [AppearProjectItem]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case start
        case end
        case items
    }
    
    public enum APIProjectType: String, Codable {
        case trigger
        case placement
        case location
    }
}

extension AppearProject {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id)
        type = try values.decode(APIProjectType.self, forKey: .type)
        name = try values.decode(String.self, forKey: .name)
        start = try? values.decodeIfPresent(Date.self, forKey: .start)
        end = try? values.decodeIfPresent(Date.self, forKey: .end)
        items = try values.decode([AppearProjectItem].self, forKey: .items)
    }
}

public struct AppearProjectItem: Decodable {
    public let id: UUID
    public let name: String
    public var trigger: TriggerProtocol
    public var media: [MediaProtocol]
}

extension AppearProjectItem {
    
    public struct VideoMedia: MediaProtocol {
        public let name: String
        public let type: MediaType
        public let url: String
        public let contentMode: ContentMode
        public let autoRepeat: Bool?
        public let position: [Double]?
        public let scale: Float32?
        public let delay: Float32?
    }
    
    public struct ModelMedia: MediaProtocol {
        public let name: String
        public let type: MediaType
        public let url: String
        public let scale: Float32
        public let autoRepeat: Bool?
        public let position: [Double]?
        public let delay: Float32?
    }
    
    public struct TextMedia: MediaProtocol {
        public var type: AppearProjectItem.MediaType
        public var url: String
        public var name: String
    }
    
    public struct ImageMedia: TriggerProtocol {
        public let width: Float32?
        public let type: TriggerType
        public let url: String
    }
    
    public struct ObjectMedia: TriggerProtocol {
        public let type: TriggerType
        public let url: String
    }
    
    public enum MediaType: String, Decodable {
        case model
        case video
    }
    
    public enum TriggerType: String, Decodable {
        case image
        case object
    }
    
    public enum ContentMode: String, Decodable {
        case scaleToFill
        case aspectFill
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case trigger
        case media
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)


        if let image = try? container.decode(ImageMedia.self, forKey: .trigger) {
            self.trigger = image
        } else if let object = try? container.decode(ObjectMedia.self, forKey: .trigger) {
            self.trigger = object
        } else {
            fatalError()
        }
        
        var mediaDict = [MediaProtocol]()
        var mediaContainer = try container.nestedUnkeyedContainer(forKey: .media)
        
        while !mediaContainer.isAtEnd {
            if let video = try? mediaContainer.decodeIfPresent(VideoMedia.self) {
                mediaDict.append(video)
            } else if let model = try? mediaContainer.decodeIfPresent(ModelMedia.self) {
                mediaDict.append(model)
            } else {
                fatalError()
            }
        }
        
        if !mediaDict.isEmpty {
            self.media = mediaDict
        } else {
            fatalError("no media after decoding")
        }

    }
}
