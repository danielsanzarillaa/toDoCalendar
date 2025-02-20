import SwiftUI

struct EmptyStateView: View {
    let presenter: ToDoPresenter
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: 8) {
                    Text("No hay tareas pendientes")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Ve al calendario para añadir tareas en el día que quieras")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            NavigationLink(destination: CalendarView(presenter: presenter)) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Ir al Calendario")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding()
    }
} 