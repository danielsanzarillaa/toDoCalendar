import SwiftUI

struct ToDoView: View {
    @ObservedObject var presenter: ToDoPresenter
    @State private var editMode = EditMode.inactive
    @State private var taskToEdit: ToDoTaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            if todayTasks.isEmpty && groupedFutureTasks.isEmpty {
                EmptyStateView(presenter: presenter)
            } else {
                List {
                    if !todayTasks.isEmpty {
                        Section(
                            header: Text("Tareas de Hoy")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                        ) {
                            ForEach(todayTasks) { task in
                                TaskRow(task: task, isEditing: editMode == .active)
                                    .onTapGesture {
                                        if editMode == .active {
                                            taskToEdit = task
                                        } else {
                                            presenter.toggleTaskCompleted(id: task.id)
                                        }
                                    }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    presenter.deleteTask(id: todayTasks[index].id)
                                }
                            }
                        }
                    }
                    
                    ForEach(groupedFutureTasks.keys.sorted(), id: \.self) { date in
                        if let tasks = groupedFutureTasks[date] {
                            Section(
                                header: Text(formatDate(date))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.top, 8)
                            ) {
                                ForEach(tasks) { task in
                                    TaskRow(task: task, isEditing: editMode == .active)
                                        .onTapGesture {
                                            if editMode == .active {
                                                taskToEdit = task
                                            } else {
                                                presenter.toggleTaskCompleted(id: task.id)
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        presenter.deleteTask(id: tasks[index].id)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 1)
                .environment(\.defaultMinListHeaderHeight, 1)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Mis Tareas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !todayTasks.isEmpty || !groupedFutureTasks.isEmpty {
                    Button(action: { editMode = editMode == .active ? .inactive : .active }) {
                        Text(editMode == .active ? "Hecho" : "Editar")
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .sheet(item: $taskToEdit) { task in
            EditTaskView(task: task, presenter: presenter)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "EEEE, d 'de' MMMM"
        } else {
            formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        }
        
        return formatter.string(from: date).capitalized
    }
    
    private var todayTasks: [ToDoTaskItem] {
        presenter.sortedTasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            return Calendar.current.isDateInToday(taskDate)
        }
    }
    
    private var groupedFutureTasks: [Date: [ToDoTaskItem]] {
        let nonTodayTasks = presenter.sortedTasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            let startOfToday = Calendar.current.startOfDay(for: Date())
            return !Calendar.current.isDateInToday(taskDate) && taskDate >= startOfToday
        }
        
        return Dictionary(grouping: nonTodayTasks) { task in
            Calendar.current.startOfDay(for: task.taskDate ?? Date())
        }
    }
}

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

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        let previewPresenter = ToDoPresenter()

        return ToDoView(presenter: previewPresenter)
            .environmentObject(previewPresenter) // Pasamos el presenter como @EnvironmentObject
            .previewDisplayName("Vista de Tareas")
    }
}
