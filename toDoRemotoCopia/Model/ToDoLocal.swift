import Foundation



class ToDoLocal {
    private let userKey = "toDoRemotoCopiaTasks"
    
    init() {
        if CommandLine.arguments.contains("--resetUserDefaults") {
            UserDefaults.standard.removeObject(forKey: userKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func fetchTasks() -> [ToDoTaskItem] {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return [] }
        do {
            let tasks = try JSONDecoder().decode([ToDoTaskItem].self, from: data)
            return tasks
        } catch {
            print("Error al decodificar las tareas: \(error)")
            return []
        }
    }
    
    func saveTasks(_ tasks: [ToDoTaskItem]) {
        let data = try? JSONEncoder().encode(tasks)
        UserDefaults.standard.set(data, forKey: userKey)
    }
}

