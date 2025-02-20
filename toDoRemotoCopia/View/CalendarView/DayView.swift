import SwiftUI

struct DayView: View {
    @Binding var date: Date
    let tasks: [ToDoTaskItem]
    
    var body: some View {
        VStack {
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
            
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task, isEditing: false)
                }
            }
        }
    }
} 