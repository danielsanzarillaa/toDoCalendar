

import SwiftUI

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
