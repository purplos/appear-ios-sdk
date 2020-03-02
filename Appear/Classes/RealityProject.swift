//
//  RealityProject.swift
//  Appear
//
//  Created by Magnus Tviberg on 15/01/2020.
//

import Foundation

public struct RealityProject: Decodable {
    public let id: String
    public let type: String
    public let title: String
    public var media: [RealityMedia]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case media
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        type = try values.decode(String.self, forKey: .type)
        title = try values.decode(String.self, forKey: .title)
        media = try values.decode([RealityMedia].self, forKey: .media)
    }
}

public struct RealityMedia: Decodable {
    public let id: String
    public let name: String?
    public let url: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        url = try values.decode(String.self, forKey: .url)
    }
}
