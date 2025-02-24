import XCTest
@testable import toDoRemotoCopia

class ToDoPresenterTests: XCTestCase {
    
    var presenter: ToDoPresenter!
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
        presenter = ToDoPresenter()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
        presenter = nil
        super.tearDown()
    }
    
    func testLoadTasks_WhenNoTasksSaved_ShouldReturnEmptyList() {
        presenter.loadTasks()
        XCTAssertTrue(presenter.tasks.isEmpty, "La lista de tareas debería estar vacía si no hay datos guardados.")
    }
    
    func testAddTask_ShouldIncreaseTheTasks() {
        let task = presenter.addTask(title: "Nueva tarea", description: "Descripción de prueba", priority: .media)
        
        XCTAssertEqual(presenter.tasks.count, 1, "Debería haber exactamente una tarea en la lista.")
        XCTAssertEqual(task.title, "Nueva tarea", "El título de la tarea añadida no coincide.")
        XCTAssertEqual(task.description, "Descripción de prueba", "La descripción de la tarea añadida no coincide.")
        XCTAssertEqual(task.priority, .media, "La prioridad de la tarea añadida no coincide.")
    }
    
    func testToggleTaskCompleted_ShouldChangeTaskState() {
        let task = presenter.addTask(title: "Tarea test")
        let taskID = task.id
        
        presenter.toggleTaskCompleted(id: taskID)
        XCTAssertTrue(presenter.tasks.first!.isCompleted, "La tarea debería estar marcada como completada.")
        
        presenter.toggleTaskCompleted(id: taskID)
        XCTAssertFalse(presenter.tasks.first!.isCompleted, "La tarea debería estar marcada como incompleta.")
    }
    
    func testDeleteTask_ShouldRemoveTaskFromList() {
        let task = presenter.addTask(title: "Tarea a eliminar")
        let taskID = task.id
        
        presenter.deleteTask(id: taskID)
        XCTAssertTrue(presenter.tasks.isEmpty, "La lista de tareas debería estar vacía después de eliminar la única tarea.")
    }
    
    func testUpdateTask_ShouldModifyTaskDetails() {
        let task = presenter.addTask(title: "Tarea inicial", description: "Descripción inicial", priority: .baja)
        let taskID = task.id
        
        presenter.updateTask(id: taskID, newTitle: "Tarea modificada", newDescription: "Nueva descripción", newPriority: .alta)
        
        XCTAssertEqual(presenter.tasks.first?.title, "Tarea modificada", "El título de la tarea no se actualizó correctamente.")
        XCTAssertEqual(presenter.tasks.first?.description, "Nueva descripción", "La descripción de la tarea no se actualizó correctamente.")
        XCTAssertEqual(presenter.tasks.first?.priority, .alta, "La prioridad de la tarea no se actualizó correctamente.")
    }
    
    func testTodayTasks_ShouldReturnTasksForTodayOrderedByPriority() {
        let today = Date()
        let _ = presenter.addTask(title: "Baja prioridad", priority: .baja, taskDate: today)
        let _ = presenter.addTask(title: "Alta prioridad", priority: .alta, taskDate: today)
        let _ = presenter.addTask(title: "Media prioridad", priority: .media, taskDate: today)
        
        let todayTasks = presenter.todayTasks
        
        XCTAssertEqual(todayTasks.count, 3, "Debe haber tres tareas para hoy.")
        XCTAssertEqual(todayTasks[0].priority, .alta, "La primera tarea debería ser de prioridad alta.")
        XCTAssertEqual(todayTasks[1].priority, .media, "La segunda tarea debería ser de prioridad media.")
        XCTAssertEqual(todayTasks[2].priority, .baja, "La tercera tarea debería ser de prioridad baja.")
    }
    
    func testGroupedFutureTasks_ShouldGroupByDateAndOrderByPriority() {
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let _ = presenter.addTask(title: "Tarea baja", priority: .baja, taskDate: tomorrow)
        let _ = presenter.addTask(title: "Tarea alta", priority: .alta, taskDate: tomorrow)
        let _ = presenter.addTask(title: "Tarea media", priority: .media, taskDate: tomorrow)
        let groupedTasks = presenter.groupedFutureTasks
        
        XCTAssertEqual(groupedTasks.count, 1, "Debería haber un solo grupo de tareas para el futuro.")
        guard let tasksForTomorrow = groupedTasks[tomorrow] else {
            XCTFail("No se encontró la fecha esperada en groupedFutureTasks.")
            return
        }
        XCTAssertEqual(tasksForTomorrow.count, 3, "El grupo de tareas futuras debería contener tres tareas.")
        let sortedTasks = tasksForTomorrow.sorted { $0.priority.rawValue > $1.priority.rawValue }
        XCTAssertEqual(sortedTasks[0].priority, .alta, "La primera tarea del grupo debería ser de prioridad alta.")
        XCTAssertEqual(sortedTasks[1].priority, .media, "La segunda tarea debería ser de prioridad media.")
        XCTAssertEqual(sortedTasks[2].priority, .baja, "La tercera tarea debería ser de prioridad baja.")
    }
    
    func testFormatDate_ShouldReturnFormattedString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "es_ES")
        let date = formatter.date(from: "2025/03/07")!
        let expectedFormattedDate = "Viernes, 7 de marzo".capitalized
        let formattedDate = presenter.formatDate(date)
        XCTAssertEqual(formattedDate, expectedFormattedDate, "El formato de fecha no es correcto.")
    }

}
