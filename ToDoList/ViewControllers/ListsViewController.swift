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
}

// MARK: Navigation
extension ListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let currentIndexPath = tasksListTableView.indexPathForSelectedRow else { return }
        guard let vc = segue.destination as? TaskListViewController else { return }

        vc.taskList = taskLists[currentIndexPath.row]
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
