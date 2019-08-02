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
    case getNearbyProjects(lat: Double, lon: Double)
    
    var baseUrl: URL {
        return URL(string: AppearApp.databaseURLString)!
    }
    
    var apiKey: String {
        return AppearApp.apiKeyString
    }
    
    var httpMethod: HTTPMethod{
        switch self {
        case .getProject, .getNearbyProjects: return .get
        }
    }
    
    var request: URLRequest{
        let path: String
        switch self{
        case .getProject: path = "/v1/project/\(AppearApp.projectId!)"
        case .getNearbyProjects: path = "v1/c"
        }
        
        return try! requestforEndpoint(path)
    }
    
    var body: Data? {
        switch self {
        case .getProject: return nil
        case .getNearbyProjects(let lat, let lon):
            let data =  ["latitude": lat, "longitude": lon] as [String : Any]
            do {
                return try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch (let error){
                fatalError(error.localizedDescription)
            }
        }
    }
}
