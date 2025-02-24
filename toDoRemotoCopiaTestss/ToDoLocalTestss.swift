import XCTest
@testable import toDoRemotoCopia

class ToDoLocalTests: XCTestCase {
    
    var repository: ToDoLocal!
    let userDefaultsKey = "toDoRemotoCopiaTasks"
    
    override func setUp() {
        super.setUp()
        repository = ToDoLocal()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        repository = nil
        super.tearDown()
    }
    
    func testFetchTasks_WhenNoTasksSaved_ShouldReturnEmptyList() {
        let tasks = repository.fetchTasks()
        XCTAssertTrue(tasks.isEmpty, "La lista de tareas debería estar vacía cuando no hay datos guardados.")
    }
    
    func testSaveAndFetchTasks_ShouldReturnCorrectData() {
        let sampleTasks = [
            ToDoTaskItem(title: "Tarea 1", description: "Descripción 1", isCompleted: false, priority: .baja),
            ToDoTaskItem(title: "Tarea 2", description: "Descripción 2", isCompleted: true, priority: .alta),
            ToDoTaskItem(title: "Tarea 3", description: "Descripción 3", isCompleted: false, priority: .media)
        ]
        
        repository.saveTasks(sampleTasks)
        let fetchedTasks = repository.fetchTasks()
        XCTAssertEqual(fetchedTasks.count, sampleTasks.count, "El número de tareas recuperadas debe coincidir con el guardado.")
        
        for (index, task) in fetchedTasks.enumerated() {
            XCTAssertEqual(task.title, sampleTasks[index].title, "El título de la tarea en la posición \(index) no coincide.")
            XCTAssertEqual(task.description, sampleTasks[index].description, "La descripción de la tarea en la posición \(index) no coincide.")
            XCTAssertEqual(task.isCompleted, sampleTasks[index].isCompleted, "El estado de completado de la tarea en la posición \(index) no coincide.")
            XCTAssertEqual(task.priority, sampleTasks[index].priority, "La prioridad de la tarea en la posición \(index) no coincide.")
        }
    }
    
    func testFetchTasks_WhenCorruptedData_ShouldReturnEmptyList() {
        let invalidData = "Datos inválidos".data(using: .utf8)
        UserDefaults.standard.set(invalidData, forKey: userDefaultsKey)
        
        let tasks = repository.fetchTasks()
        
        XCTAssertTrue(tasks.isEmpty, "Si los datos en UserDefaults están corruptos, fetchTasks debería devolver una lista vacía en lugar de fallar.")
    }
    
    func testSaveTasks_ShouldOverridePreviousTasks() {
        let initialTasks = [
            ToDoTaskItem(title: "Tarea vieja 1"),
            ToDoTaskItem(title: "Tarea vieja 2")
        ]
        
        repository.saveTasks(initialTasks)
        
        let newTasks = [
            ToDoTaskItem(title: "Tarea nueva 1"),
            ToDoTaskItem(title: "Tarea nueva 2"),
            ToDoTaskItem(title: "Tarea nueva 3")
        ]
        
        repository.saveTasks(newTasks)
        let fetchedTasks = repository.fetchTasks()
        
        XCTAssertEqual(fetchedTasks.count, newTasks.count, "Las tareas antiguas deberían haber sido sobrescritas por las nuevas.")
        XCTAssertEqual(fetchedTasks[0].title, "Tarea nueva 1", "Las tareas antiguas no fueron sobrescritas correctamente.")
    }
   

    
}
