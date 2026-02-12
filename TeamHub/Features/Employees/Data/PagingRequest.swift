//
//  PagingRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation

struct PagingRequest {
    let page: Int
    let pageSize: Int

    var offset: Int {
        page * pageSize
    }
}
