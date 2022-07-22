//
//  TaskListController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 14.07.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    @IBOutlet weak var editTasksBarButton: UIBarButtonItem!

    var taskList: ToDoTaskList!

    private var currentTasks: [ToDoTask] = []
    private var completedTasks: [ToDoTask] = []

    private let cellID = "Task"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = taskList.title
        filterTaskList(taskList)
    }

    @IBAction func createTaskBarButtonTapped() {
        createTask()
    }

    @IBAction func editTasksBarButtonTapped() {
        toggleEditMode(with: editTasksBarButton)
    }

    @IBAction func clearTaskListBarButtonTapped() {
        StorageManager.shared.clearTaskList(taskList)
        currentTasks = []
        completedTasks = []
        tableView.reloadData()
    }
}

// MARK: Task manangement
extension TaskListViewController {
    private func createTask() {

        let alert = UIAlertController.createAlert(withTitle: "Новая задача")
        alert.showAlert(for: nil) { taskTitle, note in

            StorageManager.shared.createTask(with: taskTitle, and: note, to: self.taskList) { task in
                self.currentTasks.insert(task, at: self.currentTasks.count)
                let cellIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
                self.tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        present(alert, animated: true)
    }

    private func updateTask(with indexPath: IndexPath) {
        let updatingTask = getTask(with: indexPath)

        let alert = UIAlertController.createAlert(withTitle: "Обновить задачу")
        alert.showAlert(for: updatingTask) { updatingTaskTitle, updatingNote  in

            StorageManager.shared.updateTask(with: updatingTaskTitle, and: updatingNote, for: updatingTask)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        present(alert, animated: true)
    }

    private func deleteTask(with indexPath: IndexPath) {
        let deletingTask = getTask(with: indexPath)

        /* Проверял здесь массивы. И после удаления из контекста элемент удаляется из всех массивов. И из currentTasks / completedTasks и из taskList. Но вот в таком случае при удалении строки (deleteRows) вылетает ошибка. И мне приходится вручную удалять элемент из currentTasks / completedTasks массивов. C чем это может быть связано? С тем, что контекст сохраняет изменения не сразу, а с какой-то задержкой?
         */

        StorageManager.shared.deleteTask(deletingTask)

        if indexPath.section == 0 {
            currentTasks.remove(at: indexPath.row)
        } else {
            completedTasks.remove(at: indexPath.row)
        }

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func switchTaskStatus(with indexPath: IndexPath) {
        let switchingTask = getTask(with: indexPath)

        if StorageManager.shared.switchTaskStatus(switchingTask) {
            currentTasks.remove(at: indexPath.row)
//            completedTasks.append(switchingTask) //никакой разницы
            completedTasks.insert(switchingTask, at: 0)

            let cellIndex = IndexPath(row: 0, section: 1)
            tableView.moveRow(at: indexPath, to: cellIndex)
        } else {
            completedTasks.remove(at: indexPath.row)
            currentTasks.append(switchingTask)

            let cellIndex = IndexPath(row: currentTasks.count - 1, section: 0)
            tableView.moveRow(at: indexPath, to: cellIndex)
        }
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

            let task = getTask(with: indexPath)
            content.text = task.title
            content.secondaryText = task.note

            return content
        }()

        return cell
    }
}

// MARK: UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if editTasksBarButton.title == "Ред." {
            toggleEditBarButtonTitle()
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            self.deleteTask(with: indexPath)
            if self.editTasksBarButton.title == "Ред." {
                self.toggleEditBarButtonTitle()
            }
        }

        let updateAction = UIContextualAction(style: .normal, title: "Обновить") { _, _, isDone in
            self.updateTask(with: indexPath)
            self.toggleEditMode(with: self.editTasksBarButton)
            isDone(true)
        }

        let doneTitle = indexPath.section == 0 ? "Выполнено" : "Не выполнено"
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { _, _, isDone in
            self.switchTaskStatus(with: indexPath)
            isDone(true)
        }

        updateAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, updateAction, deleteAction])
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if editTasksBarButton.title != "Ред." && !tableView.isEditing {
            toggleEditBarButtonTitle()
        }
    }
}

// MARK: Private methods
extension TaskListViewController {
    private func getTask(with indexPath: IndexPath) -> ToDoTask {
        indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
    }

    private func toggleEditMode(with actionItem: UIBarButtonItem) {
        switch actionItem.title {
        case "Ред.":
            toggleEditBarButtonTitle()
            tableView.setEditing(true, animated: true)
        default:
            toggleEditBarButtonTitle()
            tableView.setEditing(false, animated: true)
        }
    }

    private func toggleEditBarButtonTitle() {
        editTasksBarButton.title = editTasksBarButton.title == "Ред." ? "Готово" : "Ред."
    }

    private func filterTaskList(_ taskList: ToDoTaskList) {
        if let tasks = taskList.tasks?.compactMap({ $0 as? ToDoTask }) {
            currentTasks = tasks.filter { $0.isComplete == false }
            completedTasks = tasks.filter { $0.isComplete == true }
        }
    }
}

