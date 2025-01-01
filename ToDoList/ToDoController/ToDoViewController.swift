//
//  ViewController.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 11/18/24.
//

import UIKit

final class ToDoViewController: UIViewController {
    
    // MARK: - UI Element
    lazy var taskLable: UILabel = {
        let label = UILabel()
        label.font = .sfProText(.regular, size: 11)
        label.text = "Нет задач"
        label.textAlignment = .center // Центрируем текст
        label.textColor = .customWhite  // Белый цвет текста
        label.translatesAutoresizingMaskIntoConstraints = false // Важно для работы констрейтов
        return label
    }()
    
    // MARK: - Private Priorites
    private let searchController = UISearchController(searchResultsController: nil)
    private var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        return toolBar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBlack
        configureView()
        setupNavigationBar()
        setupToolBar()
        
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
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
        
        // Настройка кнопки микрофона
        let micImage = UIImage(systemName: "mic.fill")
        searchController.searchBar.setImage(micImage, for: .bookmark, state: .normal)
        searchController.searchBar.tintColor = .customWhite
        searchController.searchBar.showsBookmarkButton = true
        
        // Привязка SearchController к NavigationItem
        navigationItem.searchController = searchController
    }
    
    private func setupToolBar() {
        toolBar.backgroundColor = .customGray
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Оборачиваем taskLable в UIView
        let containerView = UIView()
        containerView.addSubview(taskLable)
        
        // Устанавливаем констрейты для TextField внутри контейнера
        NSLayoutConstraint.activate([
            taskLable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            taskLable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            taskLable.topAnchor.constraint(equalTo: containerView.topAnchor),
            taskLable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            taskLable.heightAnchor.constraint(equalToConstant: 13)
        ])
        
        // Устанавливаем ширину контейнера
        containerView.widthAnchor.constraint(equalToConstant: 150).isActive = true // Устанавливаем ширину контейнера
        
        // Создаем UIBarButtonItem для TextField
        let taskCounterItem = UIBarButtonItem(customView: containerView)
        
        // Создаем кнопку
        let addTaskButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTask)
        )
        addTaskButton.tintColor = .customYellow
        
        // Гибкие спейсеры
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Устанавливаем элементы в ToolBar
        toolBar.items = [flexibleSpace, taskCounterItem, flexibleSpace, addTaskButton]
    }
    
    
    @objc private func addTask() {
        print("kjbjk")
    }
}

extension ToDoViewController: ViewConfigurable {
    func addSubviews() {
        view.addSubview(toolBar)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 49)
        ])
    }
}


//MARK: - SearchController
extension ToDoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != nil else { return }
        
        
    }
}

//MARK: - UISearchBarDelegate
extension ToDoViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
    }
}
