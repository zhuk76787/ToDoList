//
//  TaskModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/4/25.
//

import Foundation

struct TaskModel: Codable {
    var id: Int
    var todo: String
    var isCompleted: Bool
    var userId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case isCompleted = "completed"
        case userId
    }
}

struct TaskResponse: Codable {
    let todos: [TaskModel]
    let total: Int
    let skip: Int
    let limit: Int
}
