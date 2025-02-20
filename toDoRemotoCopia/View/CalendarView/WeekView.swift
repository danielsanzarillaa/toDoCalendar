import SwiftUI

struct WeekView: View {
    @Binding var selectedDate: Date
    let tasks: [ToDoTaskItem]
    
    var body: some View {
        VStack {
            // Implementación básica de la vista semanal
            Text("Vista Semanal")
                .font(.headline)
            
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task, isEditing: false)
                }
            }
        }
    }
} 