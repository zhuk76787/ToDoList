//
//  TaskService.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/14/25.
//

import Foundation

enum TaskServiceError: Error {
    case invalidRequest
}

 class TaskService {
    private let baseURL = "https://disk.360.yandex.ru/d/QWunjxshsMk-zg"
    
    func fetchTodos(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(TaskResponse.self, from: data)
                completion(.success(response.todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
