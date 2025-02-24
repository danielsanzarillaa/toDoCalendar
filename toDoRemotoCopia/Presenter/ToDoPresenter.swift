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
        newTaskDate: Date? = nil,
        newReminderDate: Date? = nil,
        newRecurrence: TaskRecurrence? = nil
    ) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            NotificationService.shared.cancelNotification(for: id)
            
            var updatedTask = tasks[index]
            if let newTitle = newTitle { updatedTask.title = newTitle }
            if let newDescription = newDescription { updatedTask.description = newDescription }
            if let newPriority = newPriority { updatedTask.priority = newPriority }
            updatedTask.taskDate = newTaskDate ?? updatedTask.taskDate
            updatedTask.reminderDate = newReminderDate
            updatedTask.recurrence = newRecurrence
            tasks[index] = updatedTask
            saveTasks()
            
            if newReminderDate != nil {
                NotificationService.shared.scheduleNotification(for: updatedTask)
            }
        }
    }
    
    var todayTasks: [ToDoTaskItem] {
           tasks.filter { task in
               guard let taskDate = task.taskDate else { return false }
               return Calendar.current.isDateInToday(taskDate)
           }
           .sorted { $0.priority.rawValue > $1.priority.rawValue }
       }
    
    var groupedFutureTasks: [Date: [ToDoTaskItem]] {
        let futureTasks = tasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            return taskDate > Date() && !Calendar.current.isDateInToday(taskDate)
        }
        var groupedTasks = Dictionary(grouping: futureTasks) { task in
            Calendar.current.startOfDay(for: task.taskDate ?? Date())
        }
        for (key, value) in groupedTasks {
            groupedTasks[key] = value.sorted { $0.priority.rawValue > $1.priority.rawValue }
        }
        
        return groupedTasks
    }

    
    func tasks(for date: Date) -> [ToDoTaskItem] {
        tasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            return Calendar.current.isDate(taskDate, inSameDayAs: date)
        }
        .sorted { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            return task1.priority.rawValue > task2.priority.rawValue
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "EEEE, d 'de' MMMM"
        } else {
            formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        }
        
        return formatter.string(from: date).capitalized
    }

    private func saveTasks() {
        repository.saveTasks(tasks)
    }
}
