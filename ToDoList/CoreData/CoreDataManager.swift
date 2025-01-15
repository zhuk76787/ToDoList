//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/8/25.
//

import CoreData
import Foundation

final class CoreDataManager {
    //MARK: - Public Priorites
    static let shared = CoreDataManager()
    
    
    // MARK: - Private Priorites
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ToDoModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - Methods Add, Fetch and Del
extension CoreDataManager {
    func addTask(taskName: String, isCompleted: Bool) {
        let task = Task(context: context)
        task.taskName = taskName
        task.isCompleted = isCompleted
        saveContext()
    }
    
    func fetchTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func updateTask(task: Task, with newName: String) {
        task.taskName = newName
        saveContext()
    }
}

extension CoreDataManager {
    func isTaskExists(withID id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check task existence: \(error)")
            return false
        }
    }
    
    func addTaskFromAPI(taskModel: TaskModel) {
        let task = Task(context: context)
        task.id = Int64(taskModel.id)
        task.taskName = taskModel.todo
        task.isCompleted = taskModel.isCompleted
        saveContext()
    }
}
