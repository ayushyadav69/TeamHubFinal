//
//  AppInteraction.swift
//  TeamHub
//
//  Created by Ayush yadav on 20/02/26.
//

import Foundation
import Combine

final class AppInteraction {
    static let shared = AppInteraction()
    let userDidInteract = PassthroughSubject<Void, Never>()
}
