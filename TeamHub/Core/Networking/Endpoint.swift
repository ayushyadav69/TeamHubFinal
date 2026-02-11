//
//  Endpoint.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
}

enum HTTPMethod: String {
    case get = "GET"
}
