//
//  Extension + UIBarButtonItem.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 24.07.2022.
//

import Foundation
import UIKit
extension UIBarButtonItem {

    func toggleEditMode(for controller: UITableView) {
        switch self.title {
        case "Ред.":
            toggleEditBarButtonTitle()
            controller.setEditing(true, animated: true)
        default:
            toggleEditBarButtonTitle()
            controller.setEditing(false, animated: true)
        }
    }

    func toggleEditBarButtonTitle() {
        self.title = self.title == "Ред." ? "Готово" : "Ред."
    }
}
