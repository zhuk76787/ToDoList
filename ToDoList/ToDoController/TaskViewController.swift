//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/1/25.
//

import UIKit
import Combine

protocol TaskCreationDelegate: AnyObject {
    func didCreateTask(task: String)
    func didUpdateTask(at index: Int, with newName: String)
}

final class TaskViewController: UIViewController {
    weak var delegate: TaskCreationDelegate?
    
    private let viewModel = TaskViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var isTextViewUpdatingFromViewModel = false
    
    var taskText: String?
    var index: Int?
    
    private lazy var taskView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .customBlack
        textView.font = .sfProText(.medium, size: 16)
        textView.textColor = .customWhite
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.returnKeyType = .default
        return textView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
        setupInitialContent()
        configureTextViewAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskView.becomeFirstResponder()
    }
    
    // MARK: - Configuration Methods
    private func setupViewController() {
        view.backgroundColor = .customBlack
        configureView()
        setupBindings()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        setupCustomBackButton()
    }
    
    private func setupInitialContent() {
        guard let taskText = taskText else { return }
        parseAndSetInitialText(taskText)
    }
    
    private func configureTextViewAppearance() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfProText(.bold, size: 34),
            .foregroundColor: UIColor.customWhite
        ]
        taskView.typingAttributes = attributes
    }
    
    // MARK: - Private Methods
    private func setupCustomBackButton() {
        var backButtonConfig = UIButton.Configuration.plain()
        backButtonConfig.title = "Назад"
        backButtonConfig.image = UIImage(systemName: "chevron.backward")
        backButtonConfig.baseForegroundColor = .customYellow
        backButtonConfig.imagePadding = 6
        backButtonConfig.contentInsets = NSDirectionalEdgeInsets(
            top: 11,
            leading: 0,
            bottom: 11,
            trailing: 0
        )
        
        let backButton = UIButton(configuration: backButtonConfig)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
        
    private func setupBindings() {
        viewModel.$formattedText
            .receive(on: RunLoop.main)
            .sink { [weak self] attributedText in
                guard let self = self else { return }
                guard !self.taskView.isFirstResponder else { return }
         
                self.isTextViewUpdatingFromViewModel = true
                let selectedRange = self.taskView.selectedRange
                self.taskView.attributedText = attributedText
                self.taskView.selectedRange = selectedRange
                self.isTextViewUpdatingFromViewModel = false
            }
            .store(in: &cancellables)
    }
    
    private func parseAndSetInitialText(_ text: String) {
        let lines = text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        
        if let firstLine = lines.first {
            viewModel.title = String(firstLine)
        }
        
        if lines.count > 1 {
            viewModel.description = String(lines[1])
        }
    }
    
    private func updateViewModelFromTextView() {
        let text = taskView.text
        guard let lines = text?.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false) else {return}
        
        if let firstLine = lines.first {
            viewModel.title = String(firstLine)
        } else {
            viewModel.title = ""
        }
        
        if lines.count > 1 {
            viewModel.description = String(lines[1])
        } else {
            viewModel.description = ""
        }
    }
    
    @objc
    private func backButtonTapped() {
        updateViewModelFromTextView()
        
        let fullText = viewModel.title + (viewModel.description.isEmpty ? "" : "\n" + viewModel.description)
        let trimmedText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch (trimmedText.isEmpty, index) {
        case (true, _):
            navigationController?.popViewController(animated: true)
            
        case (false, let index?):
            delegate?.didUpdateTask(at: index, with: trimmedText)
            navigationController?.popViewController(animated: true)
            
        case (false, nil):
            delegate?.didCreateTask(task: trimmedText)
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Configuration View
extension TaskViewController: ViewConfigurable {
    func addSubviews() {
        view.addSubview(taskView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            taskView.topAnchor.constraint(equalTo: view.topAnchor, constant: 112),
            taskView.heightAnchor.constraint(equalToConstant: 147)
        ])
    }
}

// MARK: - UITextViewDelegate
extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard !isTextViewUpdatingFromViewModel else { return }
        updateViewModelFromTextView()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Устанавливаем атрибуты для заголовка при начале редактирования
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfProText(.bold, size: 34),
            .foregroundColor: UIColor.customWhite
        ]
        textView.typingAttributes = attributes
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.customWhite
            ]
            textView.typingAttributes = attributes
        }
        return true
    }
}
