import SwiftUI

struct ProjectsView: View {
    @ObservedObject var presenter: ToDoPresenter
    @State private var showingNewProjectSheet = false
    
    var body: some View {
        List {
            Section(header: Text("Proyectos")) {
                // Aquí irá la lista de proyectos cuando los implementemos
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Proyectos")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewProjectSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            Text("Crear nuevo proyecto")
                .navigationTitle("Nuevo Proyecto")
        }
    }
} 