//
//  toDoApp.swift
//  toDo
//
//  Created by Daniel Eduardo Sanz Arilla on 11/2/25.
//

import SwiftUI

@main
struct toDoApp: App {
    @StateObject private var presenter = ToDoPresenter()
    
    init() {
        // Solicitar permiso para notificaciones al iniciar la app
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
