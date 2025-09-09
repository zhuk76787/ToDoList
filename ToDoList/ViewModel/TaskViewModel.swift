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
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: Self.normalAttributes
        )
        if let regex = try? NSRegularExpression(pattern: "\\b\\d{2}\\.\\d{2}\\.\\d{4}\\b") {
            let matches = regex.matches(in: text,
                                        range: NSRange(location: 0, length: text.utf16.count))
            for match in matches {
                attributedString.addAttributes(Self.dateAttributes, range: match.range)
            }
        }
        return attributedString
    }
}
