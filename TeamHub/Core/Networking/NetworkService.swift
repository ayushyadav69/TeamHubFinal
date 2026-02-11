//
//  NetworkService.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol NetworkService {
    func performRequest(_ endpoint: Endpoint) async throws -> Data
}
