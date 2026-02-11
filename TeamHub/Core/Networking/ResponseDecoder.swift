//
//  ResponseDecoder.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}
