//
//  TeamHubApp.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftUI
import SwiftData

@main
struct TeamHubApp: App {
    
    @State private var container = AppDIContainer()
    @State private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            
            NavigationStack(path: $coordinator.path) {
                
                EmployeeListView()
                    .navigationDestination(for: AppRoute.self) { route in
                        
                        switch route {
                            
                        case .employeeDetail(let employee):
                            DetailView(employee: employee)
                        }
                    }
            }
            .dismissKeyboardOnInteract()
            // 🔴 INJECT HERE — ON STACK ROOT
            .environment(container.employeeListViewModel)
            .environment(coordinator)
            .modelContainer(container.modelContainer)
        }
    }
}

