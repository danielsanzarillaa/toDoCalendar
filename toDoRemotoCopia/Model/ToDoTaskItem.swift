import Foundation

struct ToDoTaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var taskDate: Date?
    var reminderDate: Date?
    var recurrence: TaskRecurrence?
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String = "", 
         isCompleted: Bool = false, 
         priority: TaskPriority = .media,
         taskDate: Date? = nil,
         reminderDate: Date? = nil,
         recurrence: TaskRecurrence? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.taskDate = taskDate
        self.reminderDate = reminderDate
        self.recurrence = recurrence
    }
}

enum TaskRecurrence: String, Codable {
    case daily
    case weekly
    case monthly
    case yearly
    case custom
    
    var description: String {
        switch self {
        case .daily: return "Diariamente"
        case .weekly: return "Semanalmente"
        case .monthly: return "Mensualmente"
        case .yearly: return "Anualmente"
        case .custom: return "Personalizado"
        }
    }
}
