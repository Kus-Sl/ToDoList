//
//  ListsViewController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 19.07.2022.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet weak var tasksListTableView: UITableView!

    @IBOutlet weak var editTasksBarButton: UIBarButtonItem!

    private let cellID = "ListCell"

    private var taskLists: [ToDoTaskList] = []
    private var indexUnwindTaskList: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData(sortBy: "date")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let index = indexUnwindTaskList else { return }
        tasksListTableView.reloadRows(at: [index], with: .automatic)
    }

    @IBAction func createTaskListBarButtonTapped(_ sender: UIBarButtonItem) {
        createTaskList()
    }

    @IBAction func editTasksBarButtonTapped() {
        toggleEditMode(with: editTasksBarButton)
    }

    @IBAction func sortedControlChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0
        ? fetchData(sortBy: "date")
        : fetchData(sortBy: "title")
        tasksListTableView.reloadData()
    }
}

// MARK: Navigation
extension ListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let currentIndexPath = tasksListTableView.indexPathForSelectedRow else { return }
        guard let vc = segue.destination as? TaskListViewController else { return }

        vc.taskList = taskLists[currentIndexPath.row]
        indexUnwindTaskList = currentIndexPath
    }
}

// MARK: TaskList management
extension ListsViewController {
    private func createTaskList() {

        let alert = UIAlertController.createAlert(withTitle: "Новый список")
        alert.showAlert(for: nil) { listTitle in

            StorageManager.shared.createTaskList(listTitle) { newList in
                self.taskLists.append(newList)
                let cellIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tasksListTableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }

        present(alert, animated: true)
    }

    private func updateTaskList(with indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]

        let alert = UIAlertController.createAlert(withTitle: "Обновить список")
        alert.showAlert(for: taskList) { newListTitle in

            StorageManager.shared.updateTaskList(with: newListTitle, for: taskList)
            self.tasksListTableView.reloadRows(at: [indexPath], with: .automatic)
        }

        present(alert, animated: true)
    }

    private func deleteTaskList(with indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]

        StorageManager.shared.deleteTaskList(taskList)
        taskLists.remove(at: indexPath.row)
        tasksListTableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func switchTaskListStatus(with indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        StorageManager.shared.switchTaskListStatus(taskList)
    }
}

// MARK: UITableViewDataSource
extension ListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskList = taskLists[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.configure(with: taskList)
        return cell
    }
}

// MARK: UITableViewDelegate
extension ListsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if editTasksBarButton.title == "Ред." {
            toggleEditBarButtonTitle()
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            self.deleteTaskList(with: indexPath)
        }

        let updateAction = UIContextualAction(style: .normal, title: "Обновить") { _, _, isDone in
            self.updateTaskList(with: indexPath)
            self.toggleEditMode(with: self.editTasksBarButton)
            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: "Завершить") { _, _, isDone in
            self.switchTaskListStatus(with: indexPath)
            self.tasksListTableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }

        updateAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

        return UISwipeActionsConfiguration(actions: [doneAction, updateAction, deleteAction])
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if editTasksBarButton.title != "Ред." && !tableView.isEditing {
            toggleEditBarButtonTitle()
        }
    }
}

// MARK: Private methods
extension ListsViewController {
    private func fetchData(sortBy parameter: String) {
        StorageManager.shared.fetchData(sortBy: parameter) { tasksList in
            self.taskLists = tasksList
        }

        // Test CoreData leaks
        StorageManager.shared.testFetchData { tasks, lists in
            tasks.forEach { print("TASK", $0.title!) }
            lists.forEach { print("LIST", $0.title!) }
      }
    }

    private func toggleEditMode(with actionItem: UIBarButtonItem) {
        switch actionItem.title {
        case "Ред.":
            toggleEditBarButtonTitle()
            tasksListTableView.setEditing(true, animated: true)
        default:
            toggleEditBarButtonTitle()
            tasksListTableView.setEditing(false, animated: true)
        }
    }

    private func toggleEditBarButtonTitle() {
        editTasksBarButton.title = editTasksBarButton.title == "Ред." ? "Готово" : "Ред."
    }
}

