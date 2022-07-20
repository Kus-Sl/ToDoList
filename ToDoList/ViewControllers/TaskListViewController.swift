//
//  TaskListController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 14.07.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    var taskList: ToDoTaskList!

    private let cellID = "Task"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = taskList.title
    }

    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    @IBAction func clearContext(_ sender: UIBarButtonItem) {
//        StorageManager.shared.clearContext(taskList)
//        taskList = nil
        tableView.reloadData()
    }
}

// MARK: Private methods
extension TaskListViewController {
    private func createTask() {

        let alert = UIAlertController.createAlert(withTitle: "Новая задача")
        alert.showAlert() { [self] taskTitle in

            StorageManager.shared.saveNewTask(taskTitle) { newTask in
//                taskList.append(newTask)
//                let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
//                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        present(alert, animated: true)
    }

    private func updateTask(for indexPath: IndexPath) {

        let alert = UIAlertController.createAlert(withTitle: "Обновить задачу")

//        alert.showAlert(for: taskList[indexPath.row]) { [self] updatingTaskTitle in

//            StorageManager.shared.updateTask(with: updatingTaskTitle, updatingTask: taskList[indexPath.row])
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }

        present(alert, animated: true)
    }
}

// MARK: UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.contentConfiguration = {
            var content = cell.defaultContentConfiguration()

            if let t = taskList.tasks![indexPath.row] as? ToDoTask {
                content.text = t.title
                content.secondaryText = t.note
            }

            return content
        }()

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

//            StorageManager.shared.deleteTask(taskList[indexPath.row])
//            taskList.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateTask(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

