//
//  ViewController.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 11/18/24.
//

import UIKit
import Combine

final class ToDoViewController: UIViewController {
    
    // MARK: - UI Element
    private lazy var taskLable: UILabel = {
        let label = UILabel()
        label.font = .sfProText(.regular, size: 11)
        label.textAlignment = .center
        label.textColor = .customWhite
        label.translatesAutoresizingMaskIntoConstraints = false
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
        label.isHidden = true
        return label
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .black
        toolBar.backgroundColor = .customGray
        return toolBar
    }()
    
    // MARK: - Private Priorites
    private let viewModel = ToDoViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBlack
        configureView()
        setupNavigationBar()
        setupToolBar()
        setupBindings()
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
        let containerView = UIView()
        containerView.addSubview(taskLable)
        NSLayoutConstraint.activate([
            taskLable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            taskLable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            taskLable.topAnchor.constraint(equalTo: containerView.topAnchor),
            taskLable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            taskLable.heightAnchor.constraint(equalToConstant: 13)
        ])
        containerView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
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
    
    private func setupBindings() {
        viewModel.$tasksCountText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.taskLable.text = text
            }
            .store(in: &cancellables)
        
        viewModel.$filteredTasks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updatePlaceholderVisibility()
            }
            .store(in: &cancellables)
    }
    
    private func updatePlaceholderVisibility() {
        let isSearchActive = searchController.isActive
        let hasTasks = !viewModel.tasks.isEmpty
        let hasFilteredResults = !viewModel.filteredTasks.isEmpty
        
        let shouldShowPlaceholder = (isSearchActive && !hasFilteredResults) || (!isSearchActive && !hasTasks)
        placeholderLabel.isHidden = !shouldShowPlaceholder
    }
    
    private func syncTasks() {
        viewModel.syncTasksFromAPI()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    _ = self
                    break
                case .failure(let error):
                    print("Failed to sync tasks: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func addTask() {
        let taskViewController = TaskViewController()
        subscribeToTaskEvents(from: taskViewController)
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    private func editTask(at indexPath: IndexPath) {
        let task = viewModel.filteredTasks[indexPath.row]
        if let index = viewModel.tasks.firstIndex(where: { $0 == task }) {
            let taskViewController = TaskViewController()
            taskViewController.taskText = task.taskName
            taskViewController.index = index
            subscribeToTaskEvents(from: taskViewController)
            navigationController?.pushViewController(taskViewController, animated: true)
        }
    }
    
    private func subscribeToTaskEvents(from taskViewController: TaskViewController) {
        taskViewController.taskEventPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .create(let text):
                    self.viewModel.addTask(taskName: text)
                case .update(let index, let text):
                    self.viewModel.updateTask(at: index, with: text)
                }
            }
            .store(in: &cancellables)
    }
    
    private func shareTask(at indexPath: IndexPath) {
        let task = viewModel.filteredTasks[indexPath.row]
        let activityItems: [Any] = [task]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
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
extension ToDoViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchText(searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.updateSearchText("")
    }
}

// MARK: - UITableViewDataSource
extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoTableViewCell.identifier,
            for: indexPath
        ) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let task = viewModel.filteredTasks[indexPath.row]
        cell.configure(with: task, at: indexPath)
        
        cell.onTaskCompletionChanged = { [weak self] indexPath, isCompleted in
            guard let self = self else { return }
            
            let task = self.viewModel.filteredTasks[indexPath.row]
            task.isCompleted = isCompleted
            CoreDataManager.shared.saveContext()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if searchController.isActive {
                let task = viewModel.filteredTasks[indexPath.row]
                if let index = viewModel.tasks.firstIndex(where: { $0 == task }) {
                    viewModel.removeTask(at: index)
                }
            } else {
                viewModel.removeTask(at: indexPath.row)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ToDoViewController: UITableViewDelegate {
    
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
