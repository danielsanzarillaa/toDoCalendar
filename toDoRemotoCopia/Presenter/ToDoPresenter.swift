import Foundation

class ToDoPresenter: ObservableObject {
    @Published private(set) var tasks: [ToDoTaskItem] = []
    private let repository = ToDoLocal()
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        tasks = repository.fetchTasks()
    }
    
    func addTask(title: String,
                 description: String = "",
                 priority: TaskPriority = .media,
                 taskDate: Date? = nil,
                 reminderDate: Date? = nil,
                 recurrence: TaskRecurrence? = nil) -> ToDoTaskItem {
        let task = ToDoTaskItem(title: title,
                                description: description,
                                priority: priority,
                                taskDate: taskDate,
                                reminderDate: reminderDate,
                                recurrence: recurrence)
        tasks.append(task)
        saveTasks()
        return task
    }
    
    func toggleTaskCompleted(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        saveTasks()
    }
    
    func updateTask(
        id: UUID,
        newTitle: String? = nil,
        newDescription: String? = nil,
        newPriority: TaskPriority? = nil,
        newtaskDate: Date? = nil,
        newReminderDate: Date? = nil,
        newRecurrence: TaskRecurrence? = nil
    ) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            // Cancelar notificación existente
            NotificationService.shared.cancelNotification(for: id)
            
            var updatedTask = tasks[index]
            if let newTitle = newTitle { updatedTask.title = newTitle }
            if let newDescription = newDescription { updatedTask.description = newDescription }
            if let newPriority = newPriority { updatedTask.priority = newPriority }
            updatedTask.taskDate = newtaskDate ?? updatedTask.taskDate
            updatedTask.reminderDate = newReminderDate
            updatedTask.recurrence = newRecurrence
            tasks[index] = updatedTask
            saveTasks()
            
            // Programar nueva notificación si es necesario
            if newReminderDate != nil {
                NotificationService.shared.scheduleNotification(for: updatedTask)
            }
        }
    }
    
    var sortedTasks: [ToDoTaskItem] {
        tasks.sorted { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            return task1.priority.rawValue > task2.priority.rawValue
        }
    }
    
    var tasksByDate: [Date: [ToDoTaskItem]] {
        Dictionary(grouping: tasks) { task in
            Calendar.current.startOfDay(for: task.taskDate ?? Date())
        }
    }
    
    private func saveTasks() {
        repository.saveTasks(tasks)
    }
}
