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
        button.setImage(UIImage(named: "circle"), for: .normal)
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
        backgroundColor = .customBlack
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        selectionStyle = .none
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
        let buttonImage = isTaskCompleted ? "checkCircle" : "circle"
        checkButton.setImage(UIImage(named: buttonImage), for: .normal)
        checkButton.tintColor = isTaskCompleted ? .customYellow : .stroke
        
        guard let taskName = taskName else { return }
        let components = taskName.components(separatedBy: "\n")
        let title = components.first ?? ""
        let descriptionAndDate = components.dropFirst().joined(separator: "\n")
        
        let attributedText = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfProText(.bold, size: 16),
            .foregroundColor: isTaskCompleted ? UIColor.stroke : UIColor.customWhite
            ]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
    
        if isTaskCompleted {
              let strikethroughTitle = NSMutableAttributedString(attributedString: titleString)
              strikethroughTitle.addAttribute(
                  .strikethroughStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSRange(location: 0, length: title.count)
              )
              attributedText.append(strikethroughTitle)
          } else {
              attributedText.append(titleString)
          }
        
        if !descriptionAndDate.isEmpty {
        attributedText.append(NSAttributedString(string: "\n"))
            let formattedDescription = formatDescriptionText(descriptionAndDate, isCompleted: isTaskCompleted)
            attributedText.append(formattedDescription)
        }
               taskLabel.attributedText = attributedText
    }
    
    private func formatDescriptionText(_ text: String, isCompleted: Bool) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: isCompleted ? UIColor.stroke : UIColor.customWhite
        ]
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: text.count))
        
        if !isCompleted {
            if let regex = try? NSRegularExpression(pattern: "\\b\\d{2}\\.\\d{2}\\.\\d{4}\\b") {
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
                
                for match in matches {
                    attributedString.addAttributes([
                        .foregroundColor: UIColor.stroke
                    ], range: match.range)
                }
            }
        }
        return attributedString
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
