//
//  TaskListController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 14.07.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    private let cellID = "Task"

    private var taskList: [ToDoTask] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        StorageManager.shared.fetchData { tasks in
            taskList = tasks
        }
    }

    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    @IBAction func clearContext(_ sender: UIBarButtonItem) {
        StorageManager.shared.clearContext(taskList)
        taskList = []
        tableView.reloadData()
    }
}

// MARK: Private methods
extension TaskListViewController {
    private func createTask() {
        showAlert() { [self] taskTitle in

            StorageManager.shared.saveNewTask(taskTitle) { newTask in
                taskList.append(newTask)
                let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }
    }

    private func updateTask(for indexPath: IndexPath) {
        showAlert(for: taskList[indexPath.row], with: "Update") { [self] updatingTaskTitle in

            StorageManager.shared.updateTask(with: updatingTaskTitle, updatingTask: taskList[indexPath.row])
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    private func showAlert(for task: ToDoTask? = nil, with nameMainAction: String = "Add", mainAction: @escaping (String) -> ()) {

        let alert = UIAlertController(title: "\(nameMainAction) task", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        let mainAction = UIAlertAction(title: nameMainAction, style: .default) { _ in
            if let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty {
                mainAction(taskTitle)
            }
        }

        alert.addAction(mainAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = task?.title == nil ? "New task" : "Updating task"
            textField.text = task?.title
        }

        present(alert, animated: true)
    }
}

// MARK: UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = taskList[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StorageManager.shared.deleteTask(taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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

