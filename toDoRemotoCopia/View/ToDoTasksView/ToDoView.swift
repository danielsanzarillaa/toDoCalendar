import SwiftUI

struct ToDoView: View {
    @ObservedObject var presenter: ToDoPresenter
    @State private var editMode = EditMode.inactive
    @State private var taskToEdit: ToDoTaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            if presenter.todayTasks.isEmpty && presenter.groupedFutureTasks.isEmpty {
                EmptyStateView(presenter: presenter)
            } else {
                List {
                    if !presenter.todayTasks.isEmpty {
                        Section(
                            header: Text("Tareas de Hoy")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                        ) {
                            ForEach(presenter.todayTasks) { task in
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
                                    presenter.deleteTask(id: presenter.todayTasks[index].id)
                                }
                            }
                        }
                    }
                    
                    ForEach(presenter.groupedFutureTasks.keys.sorted(), id: \.self) { date in
                        if let tasks = presenter.groupedFutureTasks[date] {
                            Section(
                                header: Text(presenter.formatDate(date))
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
                if !presenter.todayTasks.isEmpty || !presenter.groupedFutureTasks.isEmpty {
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
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        let previewPresenter = ToDoPresenter()

        return ToDoView(presenter: previewPresenter)
            .environmentObject(previewPresenter) // Pasamos el presenter como @EnvironmentObject
            .previewDisplayName("Vista de Tareas")
    }
}
