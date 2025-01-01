//
//  ViewConfigurableProtocol.swift
//  ToDoList
//
//  Created by Дмитрий Жуков on 11/19/24.
//

import UIKit

protocol ViewConfigurable {
    func addSubviews()
    func addConstraints()
    func configureView()
}


extension ViewConfigurable where Self: UIViewController {
    func configureView() {
        addSubviews()
        addConstraints()
    }
}

