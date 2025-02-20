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
            
            // Texto que indica el día seleccionado
            Text("Tareas para el \(formatDate(selectedDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            List {
                ForEach(tasksForSelectedDate) { task in
                    TaskRow(task: task, isEditing: false)
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
                .onDelete(perform: deleteTask)
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
    
    private var tasksForSelectedDate: [ToDoTaskItem] {
        presenter.tasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            return Calendar.current.isDate(taskDate, inSameDayAs: selectedDate)
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasksForSelectedDate[index]
            presenter.deleteTask(id: task.id)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy"
        return formatter.string(from: date)
    }
}

// Vista para añadir una nueva tarea con fecha
struct AddTaskView: View {
    @ObservedObject var presenter: ToDoPresenter
    @Environment(\.presentationMode) var presentationMode
    let selectedDate: Date
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .media
    @State private var reminderDate: Date?
    @State private var recurrence: TaskRecurrence?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Título", text: $title)
                TextField("Descripción", text: $description)
                
                Section(header: Text("Prioridad")) {
                    Picker("Prioridad", selection: $priority) {
                        ForEach([TaskPriority.baja, .media, .alta], id: \.self) { priority in
                            Text(priority.text).tag(priority)
                        }
                    }
                }
                
                Section(header: Text("Recordatorio")) {
                    Toggle("Añadir recordatorio", isOn: Binding(
                        get: { reminderDate != nil },
                        set: { if $0 { reminderDate = Date() } else { reminderDate = nil } }
                    ))
                    
                    if reminderDate != nil {
                        DatePicker(
                            "Fecha de recordatorio",
                            selection: Binding(
                                get: { reminderDate ?? Date() },
                                set: { reminderDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        Picker("Repetir", selection: $recurrence) {
                            Text("No repetir").tag(nil as TaskRecurrence?)
                            ForEach([TaskRecurrence.daily, .weekly, .monthly, .yearly], id: \.self) { recurrence in
                                Text(recurrence.description).tag(recurrence as TaskRecurrence?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    let task = presenter.addTask(
                        title: title,
                        description: description,
                        priority: priority,
                        taskDate: selectedDate,
                        reminderDate: reminderDate,
                        recurrence: recurrence
                    )
                    
                    if reminderDate != nil {
                        NotificationService.shared.scheduleNotification(for: task)
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}


