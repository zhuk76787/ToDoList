//
//  ExtentionUIFont.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 11/19/24.
//

import UIKit

extension UIFont {
    enum SFPro{
        
    }
    enum SFProText: String {
        case regular = "SFProText-Regular"
        case bold = "SFProText-Bold"
        case medium = "SFProText-Medium"
    }
    
    static func sfProText(_ style: SFProText, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            fatalError("Шрифт \(style.rawValue) не найден. Убедитесь, что он добавлен в Info.plist.")
        }
        return font
    }
}

