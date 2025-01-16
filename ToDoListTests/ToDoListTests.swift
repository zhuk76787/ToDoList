//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Дмитрий Жуков on 1/15/25.
//


import XCTest

// Простая структура для задачи (замена Core Data Task)
struct MockTask {
    var id: Int
    var taskName: String
    var isCompleted: Bool
}

// Мок для Core Data Manager
class MockCoreDataManager {
    var tasks: [MockTask] = []
    var saveContextCalled = false
    var deleteTaskCalled = false
    var updateTaskCalled = false

    func addTask(id: Int, taskName: String, isCompleted: Bool) {
        let task = MockTask(id: id, taskName: taskName, isCompleted: isCompleted)
        tasks.append(task)
        saveContextCalled = true
    }

    func fetchTasks() -> [MockTask] {
        return tasks
    }

    func deleteTask(task: MockTask) {
        deleteTaskCalled = true
        tasks.removeAll { $0.id == task.id }
    }

    func updateTask(task: MockTask, with newName: String) {
        updateTaskCalled = true
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].taskName = newName
        }
    }
}

// Unit-тесты
class CoreDataManagerTests: XCTestCase {
    var mockManager: MockCoreDataManager!

    override func setUp() {
        super.setUp()
        mockManager = MockCoreDataManager()
    }

    override func tearDown() {
        mockManager = nil
        super.tearDown()
    }

    func testAddTask() {
        // Arrange
        let id = 1
        let taskName = "Test Task"
        let isCompleted = false

        // Act
        mockManager.addTask(id: id, taskName: taskName, isCompleted: isCompleted)

        // Assert
        XCTAssertEqual(mockManager.tasks.count, 1, "There should be exactly one task.")
        XCTAssertEqual(mockManager.tasks.first?.taskName, taskName, "Task name should match.")
        XCTAssertEqual(mockManager.tasks.first?.isCompleted, isCompleted, "Task completion status should match.")
        XCTAssertTrue(mockManager.saveContextCalled, "saveContext should be called.")
    }

    func testFetchTasks() {
        // Arrange
        mockManager.addTask(id: 1, taskName: "Task 1", isCompleted: false)
        mockManager.addTask(id: 2, taskName: "Task 2", isCompleted: true)

        // Act
        let fetchedTasks = mockManager.fetchTasks()

        // Assert
        XCTAssertEqual(fetchedTasks.count, 2, "There should be two tasks.")
        XCTAssertEqual(fetchedTasks[0].taskName, "Task 1", "First task name should match.")
        XCTAssertEqual(fetchedTasks[1].isCompleted, true, "Second task completion status should match.")
    }

    func testDeleteTask() {
        // Arrange
        mockManager.addTask(id: 1, taskName: "Task 1", isCompleted: false)
        mockManager.addTask(id: 2, taskName: "Task 2", isCompleted: true)
        let initialCount = mockManager.tasks.count
        let taskToDelete = mockManager.tasks[0]

        // Act
        mockManager.deleteTask(task: taskToDelete)

        // Assert
        XCTAssertEqual(mockManager.tasks.count, initialCount - 1, "Task count should decrease by 1.")
        XCTAssertFalse(mockManager.tasks.contains { $0.id == taskToDelete.id }, "Deleted task should not be in the list.")
        XCTAssertTrue(mockManager.deleteTaskCalled, "deleteTask should be called.")
    }

    func testUpdateTask() {
        // Arrange
        mockManager.addTask(id: 1, taskName: "Task 1", isCompleted: false)
        let updatedName = "Updated Task"

        // Act
        let taskToUpdate = mockManager.tasks[0]
        mockManager.updateTask(task: taskToUpdate, with: updatedName)

        // Assert
        XCTAssertEqual(mockManager.tasks[0].taskName, updatedName, "Task name should be updated.")
        XCTAssertTrue(mockManager.updateTaskCalled, "updateTask should be called.")
    }
}
