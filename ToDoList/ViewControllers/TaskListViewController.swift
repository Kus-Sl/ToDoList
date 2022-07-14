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

        taskList = ToDoTask.createTasks()
    }

    @IBAction func AddNewTask(_ sender: UIBarButtonItem) {
        createTask()
    }

    private func createTask() {
        let alert = UIAlertController(title: "New task", message: nil, preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }

            self.taskList.insert(ToDoTask(title: task), at: 0)

            let cellIndex = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

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

struct ToDoTask {
    let title: String

    static func createTasks() -> [ToDoTask] {
        [ToDoTask(title: "shower"),
         ToDoTask(title: "dinner"),
         ToDoTask(title: "walk"),
         ToDoTask(title: "study"),
         ToDoTask(title: "run"),
         ToDoTask(title: "music"),
         ToDoTask(title: "sleep"),]
    }
}

