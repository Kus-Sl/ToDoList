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
        context = persistentContainer.viewContext
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
}

// Task's methods
extension StorageManager {
    func createTask(with taskTitle: String, and note: String, to taskList: ToDoTaskList, completion: (ToDoTask) -> ()) {
        //        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        //        guard let toDoTask = NSManagedObject(entity: entityDescription, insertInto: context) as? ToDoTask else { return }

        let toDoTask = ToDoTask(context: context)
        toDoTask.title = taskTitle
        toDoTask.note = note
        toDoTask.date = Date()

        taskList.addToTasks(toDoTask)

        // не теряю ли я здесь созданный объект?
        completion(toDoTask)
        saveContext()
    }

    func updateTask(with newTaskTitle: String, and newNote: String, for updatingTask: ToDoTask) {
        if newTaskTitle != updatingTask.title {
            updatingTask.title = newTaskTitle
        }

        if newNote != updatingTask.note {
            updatingTask.note = newNote
        }
        
        saveContext()
    }

    func deleteTask(_ task: ToDoTask) {
        context.delete(task)
        saveContext()
    }

    func switchTaskStatus(_ task: ToDoTask) -> Bool {
        task.isComplete.toggle()
        saveContext()
        return task.isComplete
    }
}

// MARK: TaskList's methods
extension StorageManager {

    func createTaskList(_ listTitle: String, completion: (ToDoTaskList) -> ()) {
        let taskList = ToDoTaskList(context: context)
        taskList.title = listTitle
        taskList.date = Date()

        completion(taskList)
    }

    func updateTaskList(with newListTitle: String, for updatingList: ToDoTaskList) {
        updatingList.title = newListTitle
        saveContext()
    }

    func deleteTaskList() {

    }

    func clearTaskList(_ task : ToDoTaskList) {
        // Удаляются ли сами объекты? Не зависают в базе?
        task.tasks = nil
        saveContext()
    }
}

// MARK: Preview/Reset CD
extension StorageManager {
    func setPreviewData() {
        if !UserDefaults.standard.bool(forKey: "Preview") {
            var tasks: [ToDoTask] = []

            for ind in 0...5 {
                let task = ToDoTask(context: context)
                task.title = "Задача \(ind)"
                task.date = Date()
                task.isComplete = false
                task.note = "заметка \(ind)"

                tasks.append(task)
            }

            let _: ToDoTaskList = {
                let tasksList = ToDoTaskList(context: context)
                tasksList.title = "Превью список"
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
}

