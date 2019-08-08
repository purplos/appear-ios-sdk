//
//  AppearApp.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

public class AppearApp {
    
    public static let sharedInstance = AppearApp()
    private init() { }
    
    static let baseURLKey: String = "BaseURL"
    static let projectIdKey: String = "ProjectID"
    static let bundleIdKey: String = "BundleID"
    static let apiKey: String = "APIKey"
    
    static var databaseURLString: String!
    static var apiKeyString: String!
    static var projectId: String!
    
    static var isConfigured = false
    static var debugOptions: [AppearDebugOptions]?
    
    public static func configure(_ debugOptions: [AppearDebugOptions]? = nil) {
        if let url = Bundle.main.url(forResource: "AppearInfo", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let infoDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
                guard let bundleID = infoDictionary[bundleIdKey] as? String else {
                    AppearLogger().fatalErrorPrint(AppearError.missingBundle.errorMessage)
                }
                guard validateBundle(id: bundleID) else {
                    AppearLogger().fatalErrorPrint(AppearError.invalidBundle.errorMessage)
                }
                guard let baseUrl = infoDictionary[baseURLKey] as? String else {
                    AppearLogger().fatalErrorPrint(AppearError.missingBaseUrl.errorMessage)
                }
                guard let apiKey = infoDictionary[apiKey] as? String else {
                    AppearLogger().fatalErrorPrint(AppearError.missingAPIKey.errorMessage)
                }
                guard let projectId = infoDictionary[projectIdKey] as? String else {
                    AppearLogger().fatalErrorPrint(AppearError.missingCampaignId.errorMessage)
                }
                self.databaseURLString = baseUrl
                self.apiKeyString = apiKey
                self.projectId = projectId
                self.isConfigured = true
                self.debugOptions = debugOptions
                AppearLogger().print("baseUrl: \(baseUrl)")
                AppearLogger().print("apiKey: \(apiKey)")
                AppearLogger().print("projectId: \(projectId)")
                AppearLogger().debugPrint("AppearProject.plist is successfully validated")
            } catch (let error) {
                AppearLogger().fatalErrorPrint(error.localizedDescription)
            }
        } else {
            AppearLogger().fatalErrorPrint(AppearError.missingPlist.errorMessage)
        }
    }
    
    static func validateBundle(id: String) -> Bool{
        guard let projectBundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        guard projectBundleIdentifier == id else { return false }
        return true
    }
    
}
