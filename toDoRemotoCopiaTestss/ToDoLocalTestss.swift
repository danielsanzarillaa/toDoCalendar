import XCTest
@testable import toDoRemotoCopia

class ToDoLocalTests: XCTestCase {
    
    var repository: ToDoLocal!
    
    override func setUp() {
        repository = ToDoLocal()
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "toDoRemotoCopiaTasks")
        repository = nil
    }
    
    func testFetchTasks_WhenNoTasksSaved_ShouldReturnEmptyList() {
        let tasks = repository.fetchTasks()
        XCTAssertTrue(tasks.isEmpty, "La lista de tareas debería estar vacía cuando no hay datos guardados .")
    }
    
    func testSaveTasksWithDescription_AndFetchTasks_ShoulReturnTheSame() {
        let tasks = [
            ToDoTaskItem(title: "Tarea 1"),
            ToDoTaskItem(title: "Tarea 2", isCompleted: true),
            ToDoTaskItem(title: "Tarea 3", description: "Descri")
        ]
        repository.saveTasks(tasks)
        let fetchedTasks = repository.fetchTasks()
        XCTAssertEqual(fetchedTasks.count, tasks.count, "El número de tareas recuperadas debe ser el mismo que el guardado, 3 en este caso.")
        XCTAssertEqual(fetchedTasks[0].title, "Tarea 1", "El título de la primera tarea no coincide.")
        XCTAssertTrue(fetchedTasks[1].isCompleted, "El estado de completado de la segunda tarea debería ser verdadero.")
        XCTAssertEqual(fetchedTasks[2].description, "Descri", "La descripción de la tercera tarea no coincide.")
    }
    
    func testFetchTasks_WhenCorruptedData_ShouldReturnEmptyList() {
        let invalidData = "Esto no es un JSON válido".data(using: .utf8)
        UserDefaults.standard.set(invalidData, forKey: "toDoTasks")
        let tasks = repository.fetchTasks()
        XCTAssertTrue(tasks.isEmpty, "Si los datos están corruptos, fetchTasks debería devolver una lista vacía en lugar de fallar.")
    }
}
