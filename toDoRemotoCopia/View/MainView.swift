import SwiftUI

struct MainView: View {
    @StateObject private var presenter = ToDoPresenter()
    
    var body: some View {
        TabView {
            NavigationView {
                ToDoView(presenter: presenter)
            }
            .tabItem {
                Label("Tareas", systemImage: "checklist")
            }
            
            NavigationView {
                CalendarView(presenter: presenter)
            }
            .tabItem {
                Label("Calendario", systemImage: "calendar")
            }
        }
        .onAppear {
            // Asegurarse de que las tareas se carguen solo una vez
            presenter.loadTasks()
        }
    }
} 
