//
//  ViewController.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 11/18/24.
//

import UIKit

final class ToDoViewController: UIViewController {
    
    // MARK: - UI Element
    private lazy var taskLable: UILabel = {
        let label = UILabel()
        label.font = .sfProText(.regular, size: 11)
        label.textAlignment = .center // Центрируем текст
        label.textColor = .customWhite  // Белый цвет текста
        label.translatesAutoresizingMaskIntoConstraints = false // Важно для работы констрейтов
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .customBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ToDoTableViewCell.self,
            forCellReuseIdentifier: ToDoTableViewCell.identifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 106
        tableView.reloadData()
        return tableView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textColor = .customWhite
        label.textAlignment = .center
        label.font = .sfProText(.bold, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // По умолчанию скрыт
        return label
    }()
    
    // MARK: - Private Priorites
    private let searchController = UISearchController(searchResultsController: nil)
    private var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    
    private let viewModel = TaskViewModel()
    private var filteredTasks: [Task] = []
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBlack
        taskLable.text = "\(viewModel.task.count) задач"
        configureView()
        setupNavigationBar()
        setupToolBar()
        syncTasks()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Задачи"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.customWhite,
            .font: UIFont.sfProText(.bold, size: 34)
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Настройка SearchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.backgroundColor = .customGray
        searchTextField.textColor = .customWhite
        searchTextField.font = UIFont.sfProText(.regular, size: 17)
        
        let micImage = UIImage(systemName: "mic.fill")
        searchController.searchBar.setImage(
            micImage,
            for: .bookmark,
            state: .normal
        )
        searchController.searchBar.tintColor = .customWhite
        searchController.searchBar.showsBookmarkButton = true
        navigationItem.searchController = searchController
    }
    
    private func setupToolBar() {
        toolBar.barStyle = .black
        toolBar.backgroundColor = .customGray
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let containerView = UIView()
        containerView.addSubview(taskLable)
        NSLayoutConstraint.activate([
            taskLable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            taskLable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            taskLable.topAnchor.constraint(equalTo: containerView.topAnchor),
            taskLable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            taskLable.heightAnchor.constraint(equalToConstant: 13)
        ])
        containerView.widthAnchor.constraint(equalToConstant: 150).isActive = true // Устанавливаем ширину контейнера
        let taskCounterItem = UIBarButtonItem(customView: containerView)
        let addTaskButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTask)
        )
        addTaskButton.tintColor = .customYellow
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolBar.items = [flexibleSpace, taskCounterItem, flexibleSpace, addTaskButton]
    }
    
    
    @objc private func addTask() {
        let taskViewController = TaskViewController()
        taskViewController.delegate = self
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    private func syncTasks() {
        viewModel.syncTasksFromAPI { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to sync tasks: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.taskLable.text = "\(self.viewModel.task.count) задач"
                }
            }
        }
    }
    
    private func shareTask(at index: IndexPath) {
        let taskShared =  viewModel.task[index.row]
        let activityItems: [Any] = [taskShared]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .saveToCameraRoll]
        present(activityViewController, animated: true)
    }
}

// MARK: - Configuration View
extension ToDoViewController: ViewConfigurable {
    func addSubviews() {
        [tableView, toolBar, placeholderLabel].forEach {
            view.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 49),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


//MARK: - SearchController
extension ToDoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            filteredTasks = []
            tableView.reloadData()
            return
        }
        filteredTasks = viewModel.task.filter { $0.taskName?.lowercased().contains(query.lowercased()) == true }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension ToDoViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        filteredTasks = []
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchController.isActive ? filteredTasks.count : viewModel.task.count
        placeholderLabel.isHidden = count > 0 || !searchController.isActive// Скрываем плейсхолдер, если есть задачи
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let task = searchController.isActive ? filteredTasks[indexPath.row] : viewModel.task[indexPath.row]
        cell.configure(with: task, at: indexPath)
        
        cell.onTaskCompletionChanged = { [weak self] indexPath, isCompleted in
            guard let self = self else { return }
            
            let taskToUpdate = self.searchController.isActive ? self.filteredTasks[indexPath.row] : self.viewModel.task[indexPath.row]
            taskToUpdate.isCompleted = isCompleted
            CoreDataManager.shared.saveContext()
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if searchController.isActive {
                let taskToDelete = filteredTasks[indexPath.row]
                if let index = viewModel.task.firstIndex(where: { $0 == taskToDelete }) {
                    viewModel.removeTask(at: index)
                }
                filteredTasks.remove(at: indexPath.row)
            } else {
                viewModel.removeTask(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            taskLable.text = "\(viewModel.task.count) задач"
        }
    }
}

// MARK: - UITableViewDelegate
extension ToDoViewController: UITableViewDelegate {
    
    func editTask(at indexPath: IndexPath) {
        let task = viewModel.task[indexPath.row]
        let taskViewController = TaskViewController()
        taskViewController.delegate = self
        taskViewController.taskText = task.taskName
        taskViewController.index = indexPath.row
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.editTask(at: indexPath)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareTask(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.tableView(tableView, commit: .delete, forRowAt: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}

// MARK: - Delegate for TaskViewController
extension ToDoViewController: TaskCreationDelegate {
    func didCreateTask(task: String) {
        viewModel.addTask(taskName: task)
        let newIndexPath = IndexPath(row: viewModel.task.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        taskLable.text = "\(viewModel.task.count) задач"
    }
    
    func didUpdateTask(at index: Int, with newName: String) {
        viewModel.updateTask(at: index, with: newName)
        tableView.reloadData()
    }
}
