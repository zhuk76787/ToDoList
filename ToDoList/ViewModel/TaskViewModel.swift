//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/4/25.
//

import Foundation

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
}
