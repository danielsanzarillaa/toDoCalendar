import SwiftUI

struct MonthView: View {
    @Binding var selectedDate: Date
    let tasks: [ToDoTaskItem]
    
    var body: some View {
        VStack {
            // Implementación básica de la vista mensual
            Text("Vista Mensual")
                .font(.headline)
            
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task, isEditing: false)
                }
            }
        }
    }
} 