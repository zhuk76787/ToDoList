//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/1/25.
//

import UIKit

protocol TaskCreationDelegate: AnyObject {
    func didCreateTask(task: String)
    func didUpdateTask(at index: Int, with newName: String)
}

final class TaskViewController: UIViewController {
    weak var delegate: TaskCreationDelegate?
    
    var taskText: String? 
    var index: Int?
    
    lazy var taskView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .customBlack
        textView.font = .sfProText(.medium, size: 16)
        textView.textColor = .customWhite
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .customBlack
        setupCustomBackButton()
        configureView()
        
        if let taskText = taskText {
            taskView.text = taskText
        }
    }
    
    // MARK: - Private Metods
    private func setupCustomBackButton() {
        var backBattonConfig = UIButton.Configuration.plain()
        backBattonConfig.title = "Назад"
        backBattonConfig.image = UIImage(systemName: "chevron.backward")
        backBattonConfig.baseForegroundColor = .customYellow
        backBattonConfig.imagePadding = 6
        backBattonConfig.contentInsets = NSDirectionalEdgeInsets(
            top: 11,
            leading: 0,
            bottom: 11,
            trailing: 0
        )
        
        let backButton = UIButton(configuration: backBattonConfig)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc
    private func backButtonTapped() {
        let trimmedText = taskView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch (trimmedText.isEmpty, index) {
        case (true, _): // Если текст пустой, просто закрыть экран
            navigationController?.popViewController(animated: true)
            
        case (false, let index?): // Обновление существующей задачи
            delegate?.didUpdateTask(at: index, with: trimmedText)
            navigationController?.popViewController(animated: true)
            
        case (false, nil): // Создание новой задачи
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
        // Обновление текста при редактировании
        formatTextView(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Если текст пустой, задаем заголовок
        if textView.text.isEmpty {
            let placeholderText = NSMutableAttributedString(
                string: "",
                attributes: [.font: UIFont.sfProText(.bold, size: 34)]
            )
            textView.attributedText = placeholderText
        }
    }
    
    func formatTextView(_ textView: UITextView) {
        // Сохраняем текущую позицию курсора
        let selectedRange = textView.selectedRange
        
        // Разделяем текст на строки
        let lines = textView.text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        
        let attributedText = NSMutableAttributedString()
        
        // Форматирование заголовка
        if let title = lines.first {
            attributedText.append(
                NSAttributedString(
                    string: String(title),
                    attributes: [
                        .font: UIFont.sfProText(.bold, size: 34), // Заголовок жирным
                        .foregroundColor: UIColor.customWhite
                    ]
                )
            )
        }
        
        // Форматирование описания
        if lines.count > 1 {
            attributedText.append(NSAttributedString(string: "\n"))
            
            // Форматируем описание с проверкой на даты
            let descriptionText = String(lines[1])
            let formattedDescription = formatDatesInText(descriptionText)
            attributedText.append(formattedDescription)
        }
        
        // Обновляем текстовое поле
        textView.attributedText = attributedText
        
        // Восстанавливаем позицию курсора
        textView.selectedRange = selectedRange
    }
    
    private func formatDatesInText(_ text: String) -> NSAttributedString {
        let words = text.split(separator: " ")
        let attributedText = NSMutableAttributedString()
        
        for word in words {
            if isValidDate(String(word)) {
                // Если это дата, добавляем ее серым цветом
                attributedText.append(
                    NSAttributedString(
                        string: "\(word) ",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 16),
                            .foregroundColor: UIColor.stroke
                        ]
                    )
                )
            } else {
                // Остальной текст обычным цветом
                attributedText.append(
                    NSAttributedString(
                        string: "\(word) ",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 16),
                            .foregroundColor: UIColor.customWhite
                        ]
                    )
                )
            }
        }
        
        return attributedText
    }
    
    private func isValidDate(_ text: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        return dateFormatter.date(from: text) != nil
    }
}
