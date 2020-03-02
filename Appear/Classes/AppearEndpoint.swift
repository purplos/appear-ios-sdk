//
//  AppearEndpoint.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

//MARK: - UserEndpoints
public enum AppearEndpoint: Endpoint{
    case getProject
    case mediaWithID(String)
    
    var baseUrl: URL {
        return URL(string: AppearApp.databaseURLString)!
    }
    
    var apiKey: String {
        return AppearApp.apiKeyString
    }
    
    var httpMethod: HTTPMethod{
        switch self {
        case .getProject, .mediaWithID: return .get
        }
    }
    
    var request: URLRequest{
        let path: String
        switch self{
        case .getProject: path = "projects/\(AppearApp.projectId!)/content"
        case .mediaWithID(let id): path = "projects/\(AppearApp.projectId!)/content/\(id)"
        }
        
        return try! requestforEndpoint(path)
    }
    
    var body: Data? {
        switch self {
        case .getProject, .mediaWithID: return nil
        }
    }
}
