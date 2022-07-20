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
    private let context: NSManagedObjectContext

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {
        context =  persistentContainer.viewContext
    }

    func fetchData(completion: ([ToDoTaskList]) -> ()) {

        let fetchRequest = ToDoTaskList.fetchRequest()

        do {
            let tasksList = try context.fetch(fetchRequest)
            completion(tasksList)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }

    //    func fetchData(completion: ([ToDoTask]) -> ()) {
    //
    //        let fetchRequest = ToDoTask.fetchRequest()
    //
    //        do {
    //            let tasks = try context.fetch(fetchRequest)
    //            completion(tasks)
    //        } catch let error {
    //            print("Failed to fetch data", error)
    //        }
    //    }

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

    func saveNewTask(_ taskTitle: String, completion: (ToDoTask) -> ()) {
        //        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        //        guard let toDoTask = NSManagedObject(entity: entityDescription, insertInto: context) as? ToDoTask else { return }
        let toDoTask = ToDoTask(context: context)
        toDoTask.title = taskTitle
        completion(toDoTask)
        saveContext()
    }

    func updateTask(with newTaskTitle: String, updatingTask: ToDoTask) {
        updatingTask.title = newTaskTitle
        saveContext()
    }

    func deleteTask(_ task: ToDoTask) {
        context.delete(task)
        saveContext()
    }

    func clearContext(_ tasks : [ToDoTask]) {
        for task in tasks {
            context.delete(task)
        }

        saveContext()
    }

    func resetCoreData() {
        let persistentCoordinator = persistentContainer.persistentStoreCoordinator
        guard let persistentStore = persistentCoordinator.persistentStores.first else { return }

        try! persistentCoordinator.destroyPersistentStore(
            at: persistentStore.url!,
            ofType: persistentStore.type,
            options: nil
        )

        UserDefaults.standard.set(false, forKey: "Preview")
    }

    // MARK: Preview method
    func setPreviewData() {
        if !UserDefaults.standard.bool(forKey: "Preview") {

            var tasks: [ToDoTask] = []

            for ind in 0...5 {
                let task = ToDoTask(context: context)
                task.title = "Title \(ind)"
                task.date = Date()
                task.isComplete = false
                task.note = "note \(ind)"

                tasks.append(task)
            }

            let _: ToDoTaskList = {
                let tasksList = ToDoTaskList(context: context)
                tasksList.title = "Preview List"
                tasksList.date = Date()

                tasksList.addToTasks(NSOrderedSet(array: tasks))

                return tasksList

            }()

            DispatchQueue.main.async {
                StorageManager.shared.saveContext()
                UserDefaults.standard.set(true, forKey: "Preview")
            }
        }
    }
}

