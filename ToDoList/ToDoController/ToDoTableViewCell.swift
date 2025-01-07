//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/3/25.
//

//import UIKit

//final class ToDoTableViewCell: UITableViewCell {
//    // MARK: - Public Properties
//    static let identifier = "ToDoCell"
//    
//    // MARK: - UI Element
//    private lazy var checkButton: UIButton = {
//        let button = UIButton()
//        button.setImage( UIImage(systemName: "circle"), for: .normal)
//        return button
//    }()
//    
//    private lazy var taskLable: UITextField = {
//        let lable = UITextField()
//        lable.textColor = .customWhite
//        lable.translatesAutoresizingMaskIntoConstraints = false
//        return lable
//    }()
//    
//    // MARK: - Initializers
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        backgroundColor = .customBlack
//        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        layer.maskedCorners = []
//        
//        configureView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with task: [String: Any]) {
//        // Извлечение данных из словаря
//        if let taskName = task["taskName"] as? String {
//            taskLable.text = taskName
//        }
//    }
//}
//
//
//extension ToDoTableViewCell: ViewConfigurable {
//    func addSubviews() {
//        contentView.addSubview(taskLable)
//    }
//    
//    func addConstraints() {
//        NSLayoutConstraint.activate([
//            taskLable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            taskLable.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - Private Methods
//    internal func  configureView() {
//        addSubviews()
//        addConstraints()
//    }
//}
import UIKit

final class ToDoTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "ToDoCell"
    
    // Замыкание для уведомления об изменении состояния задачи
        var onTaskCompletionChanged: ((IndexPath, Bool) -> Void)?
        
    
    // MARK: - UI Elements
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .stroke
        button.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Properties
    private var isTaskCompleted: Bool = false
      private var indexPath: IndexPath?
    private var taskName: String?
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
        func configure(with task: [String: Any], at indexPath: IndexPath) {
            guard let taskName = task["taskName"] as? String else { return }
            self.taskName = taskName // Сохраняем текст задачи
            
            if let isCompleted = task["isCompleted"] as? Bool {
                isTaskCompleted = isCompleted
            }
            
            updateUIForCompletionState() // Обновляем интерфейс
            self.indexPath = indexPath
        }
        
        // MARK: - UI Updates
        private func updateUIForCompletionState() {
            let buttonImage = isTaskCompleted ? "checkmark.circle.fill" : "circle"
            checkButton.setImage(UIImage(systemName: buttonImage), for: .normal)
            checkButton.tintColor = isTaskCompleted ? .customYellow : .stroke
            
            // Разделяем текст и создаем атрибутированный текст
            guard let taskName = taskName else { return }
            let components = taskName.components(separatedBy: "\n")
            let title = components.first ?? ""
            let descriptionAndDate = components.dropFirst().joined(separator: "\n")
            
            let attributedText = NSMutableAttributedString(
                string: "\(title)\n",
                attributes: [
                    .font: UIFont.sfProText(.bold, size: 16),
                    .foregroundColor: isTaskCompleted ? UIColor.stroke : UIColor.customWhite
                ]
            )
            
            attributedText.append(NSAttributedString(
                string: descriptionAndDate,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: isTaskCompleted ? UIColor.stroke : UIColor.stroke
                ]
            ))
            
            // Добавляем зачеркнутый стиль, если задача завершена
            if isTaskCompleted {
                attributedText.addAttributes(
                    [.strikethroughStyle: NSUnderlineStyle.single.rawValue],
                    range: NSRange(location: 0, length: attributedText.length)
                )
            }
            
            taskLabel.attributedText = attributedText
        }
        
        // MARK: - Actions
        @objc private func didTapCheckButton() {
            isTaskCompleted.toggle()
            updateUIForCompletionState()
            
            // Уведомляем об изменении состояния задачи
            if let indexPath = indexPath {
                onTaskCompletionChanged?(indexPath, isTaskCompleted)
            }
        }
}

// MARK: - ViewConfigurable
extension ToDoTableViewCell: ViewConfigurable {
    func addSubviews() {
        contentView.addSubview(checkButton)
        contentView.addSubview(taskLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            checkButton.widthAnchor.constraint(equalToConstant: 24),
            checkButton.heightAnchor.constraint(equalToConstant: 48),

            taskLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            taskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureView() {
        addSubviews()
        addConstraints()
    }
}
