//
//  HTTPResponseError.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import Foundation

enum HTTPResponseError: Error {
    case noInternet
    case cannotParse
    case connectionFailure(ConnectionFailureReason)
    case responseErrorWith(message: String)
    case serverError(ErrorModel)
    case serverErrorWith(statusCode: Int)
    case unauthorized
    case generic(error: Error)
}

enum ConnectionFailureReason: String {
    case emptyResponse = "Fikk ingenting tilbake fra serveren"
    case generic = "Får en ukjent feilmelding fra serveren"
}

extension HTTPResponseError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Ingen internettforbindelse"
        case .connectionFailure(let errorMessage):
            return errorMessage.rawValue
        case .cannotParse:
            return "Kunne ikke dekode responsen"
        case .unauthorized:
            return "Autentisering feilet 😧"
        case .generic:
            return "Det skjedde en feil"
        case .serverError(let errorModel):
            return errorModel.error
        case .serverErrorWith(let statusCode):
            return description(of: statusCode)
        case .responseErrorWith(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return "Sjekk om du er tilkoblet et Wi-Fi nettverk eller om du har mobildekning"
        case .serverError:
            return "Kontakt Telenor dersom problemet vedvarer"
        case .connectionFailure:
            return "Prøv igjen"
        case .cannotParse:
            return nil
        case .unauthorized:
            return "Prøv å logge ut og inn"
        default:
            return "Vennligst prøv på nytt"
        }
    }
}

extension HTTPResponseError {
    
    private func description(of httpStatusCode: Int?) -> String {
        guard let statusCode = httpStatusCode else {
            return ""
        }
        switch statusCode {
        case 400:
            return "(400) Ugyldig etterspørsel"
        case 401:
            return "(401) Ikke autorisert"
        case 403:
            return "(403) Mangler tillatelse"
        case 404:
            return "(404) Ikke funnet"
        case 500:
            return "(500) Det skjedde en intern tjenerfeil"
        case 501:
            return "(501) Tjeneren kunne ikke innfri etterspørselen"
        case 502:
            return "(502) Ugyldig svar fra oppstrømstjeneren"
        case 503:
            return "(503) Tjeneren er nede grunnet stor pågang eller vedlikehold"
        case 504:
            return "(504) Tidsavbrudd"
        default:
            return "(\(statusCode)) Det skjedde en nettverksfeil"
        }
    }
}
