//
//  PlaceHolder.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 1/9/25.
//

import UIKit

final class TextFormatterService {
    static let shared = TextFormatterService()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    func formatTaskText(_ text: String, creationDate: Date?, isCompleted: Bool = false) -> NSAttributedString {
        let components = text.components(separatedBy: "\n")
        let title = components.first ?? ""
        let description = components.dropFirst().joined(separator: "\n")
        
        let attributedText = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfProText(.bold, size: 16),
            .foregroundColor: isCompleted ? UIColor.stroke : UIColor.customWhite
        ]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
    
        if isCompleted {
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
        
        if !description.isEmpty {
            attributedText.append(NSAttributedString(string: "\n"))
            let formattedDescription = formatDescriptionText(description, isCompleted: isCompleted)
            attributedText.append(formattedDescription)
        }
    
        if let creationDate = creationDate {
            let dateString = TextFormatterService.dateFormatter.string(from: creationDate)
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.stroke
            ]
            let dateAttrString = NSAttributedString(string: "\n\(dateString)", attributes: dateAttributes)
            attributedText.append(dateAttrString)
        }
        
        return attributedText
    }
    
    func formatDescriptionText(_ text: String, isCompleted: Bool) -> NSAttributedString {
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
}
