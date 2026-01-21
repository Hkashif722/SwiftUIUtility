//
//  APIError.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation

public enum APIError: LocalizedError {
    case invalidResponse
    case noResponse
    case noData
    case unauthorized
    case unknownError
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case customError(message: String)
    case requestFailed(Error)
    case rateLimited(retryAfter: String?, message: String)
    case badRequest([String: Any], rawJSON: String)
    case resourceGone([String: Any], rawJSON: String)
    case payloadTooLarge([String: Any], rawJSON: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid or malformed response."
            
        case .noResponse:
            return "No response received from the server."
            
        case .noData:
            return "No data was returned from the server."
            
        case .unauthorized:
            return "Authentication required. Please log in again."
            
        case .unknownError:
            return "An unknown error occurred."
            
        case .serverError(let statusCode, let message):
            return "Server error with status code: \(statusCode). \(message ?? "No additional information.")"
            
        case .decodingError(let error):
            return "Failed to decode the response. Error: \(error.localizedDescription)"
            
        case .networkError(let error):
            return "Network error occurred: \(error.localizedDescription)"
            
        case .customError(let message):
            return message
            
        case .requestFailed(let error):
            return "Request failed with error: \(error.localizedDescription)"
            
        case .rateLimited(let retryAfter, let message):
            let retryMessage = retryAfter.map { " Retry after \($0)." } ?? ""
            return "Rate limited: \(message).\(retryMessage)"
            
        case .badRequest(let dict, let rawJSON):
            return extractErrorMessage(from: dict, fallback: "Bad request. \(rawJSON)")
            
        case .resourceGone(let dict, let rawJSON):
            return extractErrorMessage(from: dict, fallback: "The requested resource is no longer available. \(rawJSON)")
            
        case .payloadTooLarge(let dict, let rawJSON):
            return extractErrorMessage(from: dict, fallback: "Request payload is too large. \(rawJSON)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func extractErrorMessage(from dict: [String: Any], fallback: String) -> String {
        if let errorDesc = dict["description"] as? String {
            return errorDesc
        }

        if let errorDesc = dict["errorDescription"] as? String {
            return errorDesc
        }
        
        if let error = dict["error"] as? String {
            return error
        }
        if let message = dict["message"] as? String {
            return message
        }
        if let detail = dict["detail"] as? String {
            return detail
        }
        return fallback
    }
    
    public var statusCode: Int? {
        switch self {
        case .serverError(let code, _):
            return code
        case .badRequest:
            return 400
        case .unauthorized:
            return 401
        case .resourceGone:
            return 410
        case .payloadTooLarge:
            return 413
        default:
            return nil
        }
    }
    
    public var rawJSON: String? {
        switch self {
        case .badRequest(_, let json),
             .resourceGone(_, let json),
             .payloadTooLarge(_, let json):
            return json
        default:
            return nil
        }
    }
}

extension APIError: @unchecked Sendable {}
