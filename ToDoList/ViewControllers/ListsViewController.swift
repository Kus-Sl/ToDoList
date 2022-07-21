//
//  ListsViewController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 19.07.2022.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet weak var tasksListTableView: UITableView!

    private let cellID = "ListCell"

    private var taskLists: [ToDoTaskList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        StorageManager.shared.fetchData { tasksList in
            self.taskLists = tasksList
        }
    }

    @IBAction func createTaskListBarButtonTapped(_ sender: UIBarButtonItem) {
        createTaskList()
    }
}

// MARK: Navigation
extension ListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let currentIndexPath = tasksListTableView.indexPathForSelectedRow else { return }
        guard let vc = segue.destination as? TaskListViewController else { return }

        vc.taskList = taskLists[currentIndexPath.row]
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

    private func updateTaskList() {

    }

    private func deleteTaskList() {

    }

    


}










// MARK: UITableViewDataSource
extension ListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.contentConfiguration = {
            var content = cell.defaultContentConfiguration()
            content.text = taskLists[indexPath.row].title
            content.secondaryText = "1"
            return content
        }()

        return cell
    }
}

// MARK: UITableViewDelegate
extension ListsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasksListTableView.deselectRow(at: indexPath, animated: true)
    }
}
