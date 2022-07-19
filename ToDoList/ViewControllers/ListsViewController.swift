//
//  ListsViewController.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 19.07.2022.
//

import UIKit

class ListsViewController: UIViewController {

    private let cellID = "ListCell"

    private var tasksList: [ToDoTasksList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        StorageManager.shared.fetchData { tasksList in
            self.tasksList = tasksList
        }
    }
}

// MARK: UITableViewDataSource
extension ListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.contentConfiguration = {
            var content = cell.defaultContentConfiguration()
            content.text = tasksList[indexPath.row].title
            content.secondaryText = "1"
            return content
        }()

        return cell
    }
}
