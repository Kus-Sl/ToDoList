//
//  Extension + UITableViewCell.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 23.07.2022.
//

import Foundation
import UIKit
extension UITableViewCell {
    func configure(with taskList: ToDoTaskList) {
        guard let tasks = taskList.tasks?.compactMap({ $0 as? ToDoTask }) else { return }
        let currentTasks = tasks.filter { $0.isComplete == false }

        var content = defaultContentConfiguration()
        content.text = taskList.title

        if tasks.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currentTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = "\(currentTasks.count)"
            accessoryType = .none
        }

        contentConfiguration = content
    }
}
