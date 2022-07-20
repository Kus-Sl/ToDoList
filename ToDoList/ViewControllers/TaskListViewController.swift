//
//  TaskListController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 14.07.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    var taskList: ToDoTaskList!

    private var currentTasks: [ToDoTask] = []
    private var completedTasks: [ToDoTask] = []

    private let cellID = "Task"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = taskList.title

        if let tasks = taskList.tasks?.compactMap({ $0 as? ToDoTask }) {
            currentTasks = tasks.filter { $0.isComplete == false }
            completedTasks = tasks.filter { $0.isComplete == true }
        }
    }

    @IBAction func createTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    @IBAction func editTasks(_ sender: UIBarButtonItem) {
        toggleEditMode(with: sender)
    }

    @IBAction func clearTaskList(_ sender: UIBarButtonItem) {
        StorageManager.shared.clearTaskList(taskList)
        currentTasks = []
        completedTasks = []
        tableView.reloadData()
    }
}

// MARK: CRUD methods
extension TaskListViewController {
    private func createTask() {

        let alert = UIAlertController.createAlert(withTitle: "Новая задача")
        alert.showAlert() { [self] taskTitle in

            StorageManager.shared.createTask(taskTitle, to: taskList) { task in
                currentTasks.insert(task, at: currentTasks.count)
                let cellIndex = IndexPath(row: currentTasks.count - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        present(alert, animated: true)
    }

    private func updateTask(for indexPath: IndexPath) {
        let updatingTask = getTask(with: indexPath)

        let alert = UIAlertController.createAlert(withTitle: "Обновить задачу")
        alert.showAlert(for: updatingTask) { [self] updatingTaskTitle in

            StorageManager.shared.updateTask(with: updatingTaskTitle, for: updatingTask)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        present(alert, animated: true)
    }

    private func deleteTask(for indexPath: IndexPath) {
        let deletingTask = getTask(with: indexPath)

        // Удалить из доп списка
        currentTasks.remove(at: indexPath.row)
        StorageManager.shared.deleteTask(deletingTask)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: UITableViewDataSource
extension TaskListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Текущие задачи" : "Завершенные задачи"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.contentConfiguration = {
            var content = cell.defaultContentConfiguration()

            let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
            content.text = task.title
            content.secondaryText = task.note

            return content
        }()

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            self.deleteTask(for: indexPath)
        }

        let updateAction = UIContextualAction(style: .normal, title: "Обновить") { _, _, isDone in
            self.updateTask(for: indexPath)
            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: "Выполнено") { _, _, isDone in
            // StorageManager.shared.done(taskList)
            // tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }

        updateAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, updateAction, deleteAction])
    }
}

// MARK: UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Private methods
extension TaskListViewController {
    private func getTask(with indexPath: IndexPath) -> ToDoTask {
        let list = indexPath.section == 0 ? currentTasks : completedTasks
        let task =  list[indexPath.row]

        return task
    }

    private func toggleEditMode(with actionItem: UIBarButtonItem) {
        switch actionItem.title {
        case "Ред.":
            actionItem.title = "Готово"
            tableView.setEditing(true, animated: true)
        default:
            actionItem.title = "Ред."
            tableView.setEditing(false, animated: true)
        }
    }
}

