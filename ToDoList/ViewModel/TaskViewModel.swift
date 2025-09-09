//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 9/8/25.
//

import Combine
import UIKit

final class TaskViewModel: ObservableObject {
    @Published var title: String = "" {
        didSet {
            updateFormattedText()
        }
    }
    @Published var description: String = "" {
        didSet {
            updateFormattedText()
        }
    }
    @Published private(set) var formattedText: NSAttributedString = NSAttributedString()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private static let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.sfProText(.bold, size: 34),
        .foregroundColor: UIColor.customWhite
    ]
    private static let normalAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16),
        .foregroundColor: UIColor.customWhite
    ]
    private static let dateAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16),
        .foregroundColor: UIColor.stroke
    ]
    
    init() {
        updateFormattedText()
    }
    
    private func updateFormattedText() {
        let attributedText = NSMutableAttributedString(
            string: title,
            attributes: Self.titleAttributes
        )
        if !description.isEmpty {
            attributedText.append(NSAttributedString(string: "\n"))
            attributedText.append(formatTextWithDates(description))
        }
        formattedText = attributedText
    }
    
    private func formatTextWithDates(_ text: String) -> NSAttributedString {
        return TextFormatterService.shared.formatTaskText(text, creationDate: Date())
    }
}
