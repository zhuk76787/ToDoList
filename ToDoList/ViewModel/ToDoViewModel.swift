//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/4/25.
//

import Combine
import UIKit

final class ToDoViewModel {
    
    // MARK: - Published Properties
    
    @Published private(set) var tasks: [Task] = []
    @Published private(set) var filteredTasks: [Task] = []
    @Published private(set) var tasksCountText: String = "0 задач"
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var searchText = CurrentValueSubject<String, Never>("")
    
    // MARK: - Initialization
    
    init () {
        setupBindings()
        loadTasks()
    }
    
    // MARK: - Public MEthods
    
    func addTask(taskName: String, isCompleted: Bool = false, creationDate: Date = Date()) {
        CoreDataManager.shared.addTask(taskName: taskName, isCompleted: isCompleted, creationDate: creationDate)
        loadTasks()
    }
    
    func removeTask(at index: Int) {
        let taskToRemove = tasks[index]
        CoreDataManager.shared.deleteTask(task: taskToRemove)
        loadTasks()
    }
    
    func updateTask(at index: Int, with newName: String, newDate: Date = Date()) {
        let taskToUpdate = tasks[index]
        CoreDataManager.shared.updateTask(task: taskToUpdate, with: newName, newDate: newDate)
        loadTasks()
    }
    
    func updateSearchText(_ text: String) {
        searchText.send(text)
    }
    
    func syncTasksFromAPI() -> AnyPublisher<Result<Void, Error>, Never> {
        return Future<Result<Void, Error>, Never> { [weak self] promise in
            TaskService().fetchTodos { result in
                switch result {
                case .success(let apiTasks):
                    DispatchQueue.global(qos: .background).async {
                        for taskModel in apiTasks {
                            if !CoreDataManager.shared.isTaskExists(withID: Int64(taskModel.id)) {
                                CoreDataManager.shared.addTaskFromAPI(taskModel: taskModel)
                            }
                        }
                        self?.loadTasks()
                        promise(.success(.success(())))
                    }
                case .failure(let error):
                    print("Failed to sync tasks: \(error)")
                    promise(.success(.failure(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        $tasks
            .map {"\($0.count) задач"}
            .assign(to: \.tasksCountText, on: self)
            .store(in: &cancellables)
        
        $tasks
            .combineLatest(searchText)
            .map {tasks, searchText in
                guard !searchText.isEmpty else { return tasks}
                return tasks.filter {
                    $0.taskName?.lowercased().contains(searchText.lowercased()) ?? false
                }
            }
            .assign(to: \.filteredTasks, on: self)
            .store(in: &cancellables)
    }
    
    private func loadTasks() {
        tasks = CoreDataManager.shared.fetchTasks()
    }
}
