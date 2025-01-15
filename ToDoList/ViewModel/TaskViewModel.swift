//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/4/25.
//

import Foundation
import UIKit

final class TaskViewModel {
    var task = CoreDataManager.shared.fetchTasks()
    
    func addTask(taskName: String, isCompleted: Bool = false) {
        CoreDataManager.shared.addTask(taskName: taskName, isCompleted: isCompleted)
        task = CoreDataManager.shared.fetchTasks()
        
    }
    
    func removeTask(at index: Int) {
        let taskToRemove = task[index]
        CoreDataManager.shared.deleteTask(task: taskToRemove)
        task.remove(at: index)
    }
    
    func updateTask(at index: Int, with newName: String) {
        let taskToUpdate = task[index]
        CoreDataManager.shared.updateTask(task: taskToUpdate, with: newName)
        task = CoreDataManager.shared.fetchTasks() // Обновляем массив задач
    }
    
    func syncTasksFromAPI(completion: @escaping (Error?) -> Void) {
            TaskService().fetchTodos { result in
                switch result {
                case .success(let tasks):
                    DispatchQueue.global(qos: .background).async {
                        for taskModel in tasks {
                            if !CoreDataManager.shared.isTaskExists(withID: Int64(taskModel.id)) {
                                CoreDataManager.shared.addTaskFromAPI(taskModel: taskModel)
                            }
                        }
                        self.task = CoreDataManager.shared.fetchTasks()
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    completion(error)
                }
            }
        }
}
