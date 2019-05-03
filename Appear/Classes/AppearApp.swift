//
//  AppearApp.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

public class AppearApp {
    
    static let sharedInstance = AppearApp()
    private init() { }
    
    static let baseURLKey: String = "BaseURL"
    static let projectIdKey: String = "ProjectID"
    static let bundleIdKey: String = "BundleID"
    static let apiKey: String = "APIKey"
    
    static var databaseURLString: String!
    static var apiKeyString: String!
    static var projectId: String!
    
    static var isConfigured = false
    
    public static func configure() {
        if let url = Bundle.main.url(forResource: "AppearInfo", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let infoDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
                guard let bundleID = infoDictionary[bundleIdKey] as? String else {
                    fatalError(AppearError.missingBundle.errorMessage)
                }
                guard validateBundle(id: bundleID) else {
                    fatalError(AppearError.invalidBundle.errorMessage)
                }
                guard let baseUrl = infoDictionary[baseURLKey] as? String else {
                    fatalError(AppearError.missingBaseUrl.errorMessage)
                }
                guard let apiKey = infoDictionary[apiKey] as? String else {
                    fatalError(AppearError.missingAPIKey.errorMessage)
                }
                guard let projectId = infoDictionary[projectIdKey] as? String else {
                    fatalError(AppearError.missingCampaignId.errorMessage)
                }
                self.databaseURLString = baseUrl
                self.apiKeyString = apiKey
                self.projectId = projectId
                self.isConfigured = true
            } catch (let error) {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError(AppearError.missingPlist.errorMessage)
        }
    }
    
    static func validateBundle(id: String) -> Bool{
        guard let projectBundleIdentifier = Bundle.main.bundleIdentifier else {
            print("ERROR: Need to set a bundle identifier for this project")
            return false
        }
        guard projectBundleIdentifier == id else {
            print("ERROR: Bundle identifier in plist needs to be the same as the project bundle identifier")
            return false
        }
        return true
    }
    
}
