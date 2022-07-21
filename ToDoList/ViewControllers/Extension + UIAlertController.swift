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

    func showAlert(for task: ToDoTask?, mainAction: @escaping (String, String) -> ()) {
        
        let nameMainAction = task == nil ? "Сохранить" : "Обновить"
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
        
        let mainAction = UIAlertAction(title: nameMainAction, style: .default) { _ in
            guard let taskTitle = self.textFields?.first?.text, !taskTitle.isEmpty
            else { return }
            guard let noteTitle = self.textFields?.last?.text, !noteTitle.isEmpty
            else { return }
            mainAction(taskTitle, noteTitle)
        }
        
        addAction(mainAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder =  "\(nameMainAction) задачу"
            textField.text = task?.title
        }

        addTextField { textField in
            textField.placeholder =  "\(nameMainAction) заметку"
            textField.text = task?.note
        }
    }

    func showAlert(for list: ToDoTaskList?, mainAction: @escaping (String) -> ()) {
        print("yes")
    }
}

