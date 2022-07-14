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
        taskList = StorageManager.shared.fetchData() ?? []
    }

    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    @IBAction func clearContext(_ sender: UIBarButtonItem) {
        StorageManager.shared.clearContext()
        taskList = []
        tableView.reloadData()
    }

    private func createTask() {
        let alert = UIAlertController(title: "New task", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            guard let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty else { return }

            StorageManager.shared.saveNewTask(taskTitle)
            taskList = StorageManager.shared.fetchData() ?? []

            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New task"
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

