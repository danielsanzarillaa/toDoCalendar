import XCTest
@testable import toDoRemotoCopia

class ToDoPresenterTests: XCTestCase {
    
    var presenter: ToDoPresenter!
    
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
        presenter = ToDoPresenter()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
        presenter = nil
    }
    
    func testLoadTasks_WhenNoTasksSaved_ShouldReturnEmptyList() {
        presenter.loadTasks()
        XCTAssertTrue(presenter.tasks.isEmpty)
    }
    
    func testAddTask_ShouldIncreaseTheTasks() {
        presenter.addTask(title: "Nueva tarea", description: "", priority: .media)
        XCTAssertEqual(presenter.tasks.count, 1)
        XCTAssertEqual(presenter.tasks.first?.title, "Nueva tarea")
    }
    
    func testToggleTaskCompleted_ShouldChangeTaskState() {
        presenter.addTask(title: "Tarea test", description: "", priority: .media)
        let taskID = presenter.tasks.first!.id
        presenter.toggleTaskCompleted(id: taskID)
        XCTAssertTrue(presenter.tasks.first!.isCompleted)
        presenter.toggleTaskCompleted(id: taskID)
        XCTAssertFalse(presenter.tasks.first!.isCompleted)
    }
    
    func testDeleteTask_ShouldRemoveTaskFromList() {
        presenter.addTask(title: "Tarea a eliminar", description: "", priority: .media)
        let taskID = presenter.tasks.first!.id
        presenter.deleteTask(id: taskID)
        XCTAssertTrue(presenter.tasks.isEmpty)
    }
    
    func testUpdateTask_ShouldModifyTaskDetails() {
        presenter.addTask(title: "Tarea inicial", description: "Descripción inicial", priority: .baja)
        let taskID = presenter.tasks.first!.id
        
        presenter.updateTask(id: taskID, newTitle: "Tarea modificada", newDescription: "Nueva descripción", newPriority: .alta)
        
        XCTAssertEqual(presenter.tasks.first?.title, "Tarea modificada")
        XCTAssertEqual(presenter.tasks.first?.description, "Nueva descripción")
        XCTAssertEqual(presenter.tasks.first?.priority, .alta)
    }
    


    
    func testSortedTasks_ShouldOrderByPriorityOnly() {
        presenter.addTask(title: "Tarea Baja", description: "", priority: .baja)
        presenter.addTask(title: "Tarea Alta", description: "", priority: .alta)
        presenter.addTask(title: "Tarea Media", description: "", priority: .media)
        
        let sortedTasks = presenter.sortedTasks
        
        XCTAssertEqual(sortedTasks[0].priority, .alta, "La primera tarea debería ser de prioridad alta")
        XCTAssertEqual(sortedTasks[1].priority, .media, "La segunda tarea debería ser de prioridad media")
        XCTAssertEqual(sortedTasks[2].priority, .baja, "La tercera tarea debería ser de prioridad baja")
    }
}
