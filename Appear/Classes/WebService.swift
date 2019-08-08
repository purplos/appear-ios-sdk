//
//  WebService.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation
import UIKit

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public class WebService {
    static let sharedInstance = WebService()
    private var urlSession = URLSession()
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
    }
    
    func request(_ endpoint: Endpoint, completion: @escaping (Result<Data>) -> Void) {
        if let httpBody = endpoint.request.httpBody {
            print("Body: \(String.init(data: httpBody, encoding: .utf8)!)")
        }
        
        let token = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        let task = self.urlSession.dataTask(with: endpoint.request) { [unowned self] (data, response, error) in
            //self.logCall(jsonData: data, responseError: error, response: response)
            do {
                let validData = try self.handle(responseData: data,
                                                response: response,
                                                responseError: error)
                
                completion(.success(validData))
            } catch {
                completion(.failure(error))
            }
            UIApplication.shared.endBackgroundTask(token)
        }
        task.resume()
    }
    
    // MARK: Error handling
    
    private func handle(responseData: Data?,
                        response: URLResponse?,
                        responseError: Error?) throws -> Data {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw HTTPResponseError.unauthorized
            }
            if case 400..<600 = httpResponse.statusCode {
                throw HTTPResponseError.serverErrorWith(statusCode: httpResponse.statusCode)
            }
        }
        if let error = responseError {
            print(error.localizedDescription)
            if let urlError = error as? URLError {
                if urlError.code == .notConnectedToInternet {
                    throw HTTPResponseError.noInternet
                }
            }
            throw HTTPResponseError.connectionFailure(.generic)
        }
        guard let validData = responseData
            else {
                throw HTTPResponseError.connectionFailure(.emptyResponse)
        }
        return validData
    }
}

extension WebService {
    
    // MARK: - Logging functions
    
    func logCall(jsonData: Data?, responseError: Error?, response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }
        print("error: \(responseError?.localizedDescription ?? "NA")")
        guard let jsonData = jsonData else { return }
        let datastring = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        print("Data: \(datastring ?? "NA")")
    }
}

struct ErrorModel: Codable {
    let error: String
}
