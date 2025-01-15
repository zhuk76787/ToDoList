//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/3/25.
//

import UIKit

final class ToDoTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "ToDoCell"
    
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
    
    // MARK: - Method Configuration Cell
    func configure(with task: Task, at indexPath: IndexPath) {
        self.taskName = task.taskName
        self.isTaskCompleted = task.isCompleted
        
        updateUIForCompletionState()
        self.indexPath = indexPath
    }
    
    // MARK: - UI Updates
    private func updateUIForCompletionState() {
        let buttonImage = isTaskCompleted ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: buttonImage), for: .normal)
        checkButton.tintColor = isTaskCompleted ? .customYellow : .stroke
        
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
        
        if let indexPath = indexPath {
            onTaskCompletionChanged?(indexPath, isTaskCompleted)
        }
    }
}

// MARK: - Configuration View
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
