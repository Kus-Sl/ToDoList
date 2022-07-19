//
//  Extension + UIAlertController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 19.07.2022.
//

import UIKit

extension UIAlertController {
    
    static func createAlert(withTitle title: String) -> UIAlertController {
        UIAlertController(title: title, message: nil, preferredStyle: .alert)
    }
    
    func showAlert(for task: ToDoTask? = nil, mainAction: @escaping (String) -> ()) {

        let nameMainAction = task == nil ? "Сохранить" : "Обновить"

        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)

        let mainAction = UIAlertAction(title: nameMainAction, style: .default) { _ in
            if let taskTitle = self.textFields?.first?.text, !taskTitle.isEmpty {
                mainAction(taskTitle)
            }
        }
        
        addAction(mainAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder =  "\(nameMainAction) задачу"
            textField.text = task?.title
        }
    }
}

