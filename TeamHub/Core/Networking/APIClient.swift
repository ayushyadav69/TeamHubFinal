//
//  APIClient.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

final class APIClient {
    
    private let networkService: NetworkService
    private let decoder: ResponseDecoder
    
    init(networkService: NetworkService, decoder: ResponseDecoder) {
        self.networkService = networkService
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await networkService.performRequest(endpoint)
        return try decoder.decode(data)
    }
}
