import XCTest


//PREGUNTAR SI ES NECESARIO  BORRAR TODA LA BD  AL EMPEZAR CADA TEST DE UI, SI NO SE BORRA CREO QUE ES MUCHO LIO

final class toDoUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--resetUserDefaults") //
        app.launch()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testAddTaskWithOrWithoutDescription_ShouldReturnTrue() throws {
        let titleField = app.textFields["Título de la tarea"]
        XCTAssertTrue(titleField.exists, "El campo de título no existe")
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        XCTAssertTrue(addTaskButton.exists, "El botón de añadir tarea no existe")
        addTaskButton.tap()
        let newTaskCell = app.staticTexts["Nueva tarea"]
        XCTAssertTrue(newTaskCell.waitForExistence(timeout: 1), "La nueva tarea no se ha añadido correctamente en la UI")
    }
    
    func testAddTaskWithDescription_ShouldReturnTrue() throws {
        let titleField = app.textFields["Título de la tarea"]
        XCTAssertTrue(titleField.exists, "El campo de título no existe")
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let descriptionField = app.textFields["Descripción (opcional)"]
        XCTAssertTrue(descriptionField.exists, "El campo de descripción no existe")
        descriptionField.tap()
        descriptionField.typeText("Descripción")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        XCTAssertTrue(addTaskButton.exists, "El botón de añadir tarea no existe")
        addTaskButton.tap()
        let collectionViewsQuery = XCUIApplication().collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["chevron.down"]/*[[".cells",".buttons[\"Go Down\"]",".buttons[\"chevron.down\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let newTaskCell = app.staticTexts["Nueva tarea"]
        let newTaskDescriptionCell = app.staticTexts["Descripción"]
        XCTAssertTrue(newTaskCell.waitForExistence(timeout: 1), "La nueva tarea no se ha añadido correctamente en la UI")
        XCTAssertTrue(newTaskDescriptionCell.waitForExistence(timeout: 1), "La nueva tarea no se ha añadido correctamente en la UI")
    }
    
    func testToggleTaskCompletion_ShouldChangeState() throws {
        let titleField = app.textFields["Título de la tarea"]
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        addTaskButton.tap()
        let incompleteTaskButton = app.images["circle"]
        XCTAssertTrue(incompleteTaskButton.waitForExistence(timeout: 2), "El botón de tarea incompleta no se encontró")
        incompleteTaskButton.tap()
        let completedTaskButton = app.images["checkmark.circle.fill"]
        XCTAssertTrue(completedTaskButton.waitForExistence(timeout: 2), "El botón de tarea completada no apareció")
        completedTaskButton.tap()
        XCTAssertTrue(incompleteTaskButton.waitForExistence(timeout: 2), "La tarea no se desmarcó correctamente")
    }
    
    func testDeleteTask_ShouldDeleteNuevaTarea() throws {
        let titleField = app.textFields["Título de la tarea"]
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        addTaskButton.tap()
        let taskCell = app.staticTexts["Nueva tarea"]
        taskCell.swipeLeft()
        XCUIApplication().collectionViews.buttons["Delete"].tap()
        XCTAssertTrue(!taskCell.exists, "No se ha eliminado con exito")
    }
    
    func testEditTaskTitle_ShouldReturnTrue() throws {
        let titleField = app.textFields["Título de la tarea"]
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        addTaskButton.tap()
        XCUIApplication().navigationBars["Mis Tareas"]/*@START_MENU_TOKEN@*/.buttons["Editar"]/*[[".otherElements[\"Editar\"].buttons[\"Editar\"]",".buttons[\"Editar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Nueva tarea"]/*[[".cells.staticTexts[\"Nueva tarea\"]",".staticTexts[\"Nueva tarea\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Título de la tarea"]/*[[".cells.textFields[\"Título de la tarea\"]",".textFields[\"Título de la tarea\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.textFields["Título de la tarea"].typeText(" editada")
        app.navigationBars["Editar Tarea"]/*@START_MENU_TOKEN@*/.buttons["Guardar"]/*[[".otherElements[\"Guardar\"].buttons[\"Guardar\"]",".buttons[\"Guardar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let editedTaskCell = app.staticTexts["Nueva tarea editada"]
        XCTAssertTrue(editedTaskCell.exists, "El título de la tarea no se actualiza")
    }
    
    func testCancelWhileEditingTaskTitle_ShouldReturnTrue() throws {
        let titleField = app.textFields["Título de la tarea"]
        titleField.tap()
        titleField.typeText("Nueva tarea")
        app.buttons["Return"].tap()
        let addTaskButton = app.buttons["Añadir Tarea"]
        addTaskButton.tap()
        XCUIApplication().navigationBars["Mis Tareas"]/*@START_MENU_TOKEN@*/.buttons["Editar"]/*[[".otherElements[\"Editar\"].buttons[\"Editar\"]",".buttons[\"Editar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Nueva tarea"]/*[[".cells.staticTexts[\"Nueva tarea\"]",".staticTexts[\"Nueva tarea\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Título de la tarea"]/*[[".cells.textFields[\"Título de la tarea\"]",".textFields[\"Título de la tarea\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.textFields["Título de la tarea"].typeText(" editada")
        app.navigationBars["Editar Tarea"].buttons["Cancelar"].tap()
        let uneditedTaskCell = app.staticTexts["Nueva tarea"]
        XCTAssertTrue(uneditedTaskCell.exists, "El título de la tarea se actualiza cuando no debería")
    }
}














