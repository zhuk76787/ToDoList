//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/4/25.
//

import Foundation

final class TaskViewModel {
    var task: [[String : Any]] = [
        ["taskName": "Заняться спортом \n Сходить в спортзал или сделать тренировку дома. Не забыть про разминку и растяжку! \n 02/10/24", "isCompleted": false ],
        ["taskName": " Уборка в квартире \n Провести генеральную уборку в квартире \n 05/10/24", "isCompleted": false ],
        ["taskName": "Вечерний отдых  \n Найти время для расслабления перед сном: посмотреть фильм или послушать музыку \n 10/10/24", "isCompleted": false ]
    ]
    
    func addTask(taskName: String, isCompleted: Bool = false) {
        task.append(["taskName": taskName, "isCompleted": false])
        print("cvbjnk")
        
    }
    
    func removeTask(at index: Int) {
        task.remove(at: index)
    }
    
    func saveData() {
    }
}
