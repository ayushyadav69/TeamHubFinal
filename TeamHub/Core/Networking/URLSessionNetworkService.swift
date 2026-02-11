//
//  URLSessionNetworkService.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

final class URLSessionNetworkService: NetworkService {
    
    private let baseURL = "https://employee-static-api.onrender.com"
    
    func performRequest(_ endpoint: Endpoint) async throws -> Data {
        
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return data
    }
    
    
    
}
