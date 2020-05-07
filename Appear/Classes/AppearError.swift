//
//  AppearError.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import UIKit

enum AppearError: Error {
    case missingBundle
    case invalidBundle
    case missingBaseUrl
    case missingAPIKey
    case missingCampaignId
    case missingPlist
    case missingConfiguration
    case localModelUrlMissing
    case unableToCreateModelFromURL
    case unableToDecode(DecodeAttempt)
    case errorWithMessage(String)
    case networkingError(HTTPResponseError)
}

enum DecodeAttempt {
    case project
    case media
}

extension AppearError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .missingBundle:
            return "No bundle identifier in the plist"
        case .invalidBundle:
            return "The Bundle Identifier for this campaign does not match the Bundle Identifier for this project"
        case .missingBaseUrl:
            return "No base url in the plist"
        case .missingAPIKey:
            return "No API key in the plist"
        case .missingCampaignId:
            return "No campaign id in the plist"
        case .missingPlist:
            return "Could not find a ARCampaign.plist"
        case .missingConfiguration:
            return "AppearApp has not been configured yet"
        case .localModelUrlMissing:
            return "Missing local model URL"
        case .unableToCreateModelFromURL:
            return "Unable to create model from URL"
        case .unableToDecode(let attempt):
            switch attempt {
            case .project:
                return "Unable to decode trigger"
            case .media:
                return "Unable to decode media"
            }
        case .errorWithMessage(let message):
            return message
        case .networkingError(let responseError):
            return responseError.errorDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidBundle:
            return "Check that the Bundle Identifier in the ARCampaignInfo.plist is the same as for the project"
        case .missingPlist:
            return "Download AppearInfo.plist from https://appear.media, and add it to the project"
        case .missingConfiguration:
            return "Call AppearApp.configure() in the didFinishLaunchingWithOptions method in AppDelegate"
        case .networkingError(let responseError):
            return responseError.recoverySuggestion
        case .missingBundle, .missingBaseUrl, .missingAPIKey, .missingCampaignId, .localModelUrlMissing, .unableToCreateModelFromURL, .unableToDecode(_), .errorWithMessage(_):
            return ""
        }
    }
    
}

extension AppearError {
    
    var errorMessage: String {
        guard let errorDescription = errorDescription else { return "Ukjent feil" }
        
        if let recoverySuggestion = recoverySuggestion {
            return "\(errorDescription). \(recoverySuggestion)"
        } else {
            return errorDescription
        }
    }
}

extension UIViewController {
    
    func presentAlert(campaignError: AppearError, handler: ((UIAlertAction) -> Void)? = nil) {
        let message = campaignError.errorMessage
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "Lukk", style: .cancel, handler: handler))
        present(alertController, animated: true, completion: nil)
    }
}
