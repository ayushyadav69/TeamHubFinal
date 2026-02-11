//
//  NetworkError.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case serverError(Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .decodingFailed:
            return "Failed to decode response."
        case .serverError(let code):
            return "Server error with code \(code)."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
