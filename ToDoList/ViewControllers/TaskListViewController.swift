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

    @IBAction func createTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    @IBAction func editTasks(_ sender: UIBarButtonItem) {
    }

    @IBAction func clearTaskList(_ sender: UIBarButtonItem) {
        StorageManager.shared.clearTaskList(taskList)
        tableView.reloadData()
    }
}

// MARK: Private methods
extension TaskListViewController {
    private func createTask() {

        let alert = UIAlertController.createAlert(withTitle: "Новая задача")
        alert.showAlert() { [self] taskTitle in

            StorageManager.shared.createTask(taskTitle, to: taskList) { newTask in
                let cellIndex = IndexPath(row: (taskList.tasks?.count ?? 0) - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        present(alert, animated: true)
    }

    private func updateTask(for indexPath: IndexPath) {

        // завернуть в метод
        guard let updatingTask = taskList.tasks?[indexPath.row] as? ToDoTask else { return }

        let alert = UIAlertController.createAlert(withTitle: "Обновить задачу")
        alert.showAlert(for: updatingTask) { [self] updatingTaskTitle in

            StorageManager.shared.updateTask(with: updatingTaskTitle, for: updatingTask)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        present(alert, animated: true)
    }

    private func deleteTask(for indexPath: IndexPath) {
//         завернуть в метод
        guard let deletingTask = taskList.tasks?[indexPath.row] as? ToDoTask else { return }

        StorageManager.shared.deleteTask(deletingTask)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {


        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.deleteTask(for: indexPath)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.updateTask(for: indexPath)
            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
//            StorageManager.shared.done(taskList)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }

        editAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

