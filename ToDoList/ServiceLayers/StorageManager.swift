//
//  StorageManager.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 14.07.2022.
//

import Foundation
import CoreData


class StorageManager {

    static let shared = StorageManager()

    private let entityName = "ToDoTask"

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var context = persistentContainer.viewContext

    private init() {}

    func fetchData() -> [ToDoTask]? {
        let fetchRequest = ToDoTask.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
            return nil
        }
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveNewTask(_ taskTitle: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        guard let toDoTask = NSManagedObject(entity: entityDescription, insertInto: context) as? ToDoTask else { return }

        toDoTask.title = taskTitle

        saveContext()
    }

    func deleteTask(_ task: ToDoTask) {
        context.delete(task)

        saveContext()
    }

    func clearContext() {
        guard let tasks = fetchData() else { return }
        for task in tasks {
            context.delete(task)
        }
        
        saveContext()
    }
}

