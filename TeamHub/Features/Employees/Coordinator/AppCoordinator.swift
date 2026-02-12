//
//  AppCoordinator.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI
import Observation

@Observable
final class AppCoordinator {

    var path: [AppRoute] = []

    func goToDetail(employeeID: String) {
        path.append(.employeeDetail(id: employeeID))
    }

    func pop() {
        path.removeLast()
    }
}


