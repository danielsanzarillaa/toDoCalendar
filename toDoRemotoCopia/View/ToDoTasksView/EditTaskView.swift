import SwiftUI

struct EditTaskView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var reminderDate: Date?
    @State private var recurrence: TaskRecurrence?
    @State private var taskDate: Date
    let task: ToDoTaskItem
    let presenter: ToDoPresenter
    
    init(task: ToDoTaskItem, presenter: ToDoPresenter) {
        self.task = task
        self.presenter = presenter
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _reminderDate = State(initialValue: task.reminderDate)
        _recurrence = State(initialValue: task.recurrence)
        _taskDate = State(initialValue: task.taskDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Título")) {
                    TextField(AppConstants.Text.taskTitlePlaceholder, text: $title)
                        .disableAutocorrection(true)
                }
                Section(header: Text("Descripción")) {
                    TextField(AppConstants.Text.taskDescriptionPlaceholder, text: $description)
                        .disableAutocorrection(true)
                }
                Section(header: Text("Prioridad")) {
                    Picker("Prioridad", selection: $priority) {
                        ForEach([TaskPriority.baja, .media, .alta], id: \.rawValue) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 8, height: 8)
                                Text(priority.text)
                            }.tag(priority)
                        }
                    }
                }
                Section(header: Text("Fecha")) {
                    DatePicker(
                        "Fecha",
                        selection: $taskDate,
                        displayedComponents: [.date]
                    )
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
            .navigationTitle(AppConstants.Text.editTaskTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppConstants.Text.cancelButton) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppConstants.Text.saveButton) {
                        presenter.updateTask(
                            id: task.id,
                            newTitle: title,
                            newDescription: description,
                            newPriority: priority,
                            newtaskDate: taskDate,
                            newReminderDate: reminderDate,
                            newRecurrence: recurrence
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
