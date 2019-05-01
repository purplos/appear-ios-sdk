//
//  Endpoint.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

protocol Endpoint {
    var baseUrl           : URL { get }
    var request           : URLRequest { get }
    var httpMethod        : HTTPMethod { get }
    var apiKey            : String { get }
    var body              : Data? { get }
}

extension Endpoint {
    
    func requestforEndpoint(_ path: String, baseURL: URL? = nil) throws -> URLRequest{
        let baseURL = baseURL ?? baseUrl
        print(path)
        print(baseURL)
        guard let url = URL(string: path, relativeTo: baseURL) else {
            fatalError()
        }
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else{
            fatalError("invalid URL")
        }
        
        guard let componentURL = urlComponents.url else {
            fatalError("invalid URL")
        }
        print(componentURL)
        var request             = URLRequest(url: componentURL)
        request.httpBody        = body
        request.httpMethod      = httpMethod.rawValue
        
        if let apiKey = AppearApp.apiKeyString {
            print(apiKey)
            request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request.allHTTPHeaderFields ?? "Could not print the HTTP header fields of the receiver")
        return request
    }
}
