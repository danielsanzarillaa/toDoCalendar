import SwiftUI

struct CalendarView: View {
    @ObservedObject var presenter: ToDoPresenter
    @State private var selectedDate: Date = Date()
    @State private var showingTaskSheet = false
    @State private var taskToEdit: ToDoTaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "Seleccionar fecha",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            Text("Tareas para el \(presenter.formatDate(selectedDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            List {
                ForEach(presenter.tasks(for: selectedDate)) { task in
                    TaskRow(task: task, isEditing: false)
                        .onTapGesture {
                            presenter.toggleTaskCompleted(id: task.id)
                        }
                        .contextMenu {
                            Button(action: {
                                taskToEdit = task
                            }) {
                                Label("Editar", systemImage: "pencil")
                            }

                            Button(role: .destructive, action: {
                                presenter.deleteTask(id: task.id)
                            }) {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                }
                .onDelete { offsets in
                    offsets.forEach { index in
                        let task = presenter.tasks(for: selectedDate)[index]
                        presenter.deleteTask(id: task.id)
                    }
                }
            }

            
            Button(action: { showingTaskSheet = true }) {
                Label("Añadir tarea para esta fecha", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .padding()
            .sheet(isPresented: $showingTaskSheet) {
                AddTaskView(presenter: presenter, selectedDate: selectedDate)
            }
        }
        .sheet(item: $taskToEdit) { task in
            EditTaskView(task: task, presenter: presenter)
        }
        .navigationTitle("Calendario")
    }
}
