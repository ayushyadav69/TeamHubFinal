//
//  RoleEntity.swift
//  TeamHub
//
//  Created by Ayush yadav on 19/02/26.
//

import Foundation
import SwiftData

@Model
final class RoleEntity {

    @Attribute(.unique)
    var name: String

    init(name: String) {
        self.name = name
    }
}
