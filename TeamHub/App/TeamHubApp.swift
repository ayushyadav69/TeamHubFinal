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
    @State private var showEntry = true   // 🔥 Add this
    
    init() {
        let cache = URLCache(
            memoryCapacity: 100 * 1024 * 1024, // 100 MB RAM
            diskCapacity: 500 * 1024 * 1024,   // 500 MB disk
            diskPath: "github-image-cache"
        )

        URLCache.shared = cache
    }
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                
                if showEntry {
                    EntryView()
                } else {
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
                    .environment(container.employeeListViewModel)
                    .environment(coordinator)
                    .modelContainer(container.modelContainer)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut) {
                        showEntry = false
                    }
                }
            }
        }
    }
}
