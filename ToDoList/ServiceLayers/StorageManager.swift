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

    func fetchData(sortBy parameter: String, completion: ([ToDoTaskList]) -> ()) {

        let sortDescriptor = NSSortDescriptor(key: parameter, ascending: true)
        let fetchRequest = ToDoTaskList.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]

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

    // Test CoreData Leaks
    func testFetchData(completion: ([ToDoTask], [ToDoTaskList]) -> ()) {
        let fetchRequest = ToDoTask.fetchRequest()
        let fetchRequestList = ToDoTaskList.fetchRequest()

        do {
            let tasks = try context.fetch(fetchRequest)
            let lists = try context.fetch(fetchRequestList)
            completion(tasks, lists)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
}

// Task's methods
extension StorageManager {
    func createTask(with title: String, and note: String, to taskList: ToDoTaskList, completion: (ToDoTask) -> ()) {
        //        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        //        guard let toDoTask = NSManagedObject(entity: entityDescription, insertInto: context) as? ToDoTask else { return }

        let toDoTask = ToDoTask(context: context)
        toDoTask.title = title
        toDoTask.note = note
        toDoTask.date = Date()

        taskList.addToTasks(toDoTask)

        completion(toDoTask)
        saveContext()
    }

    func update(task: ToDoTask, with newTitle: String, and newNote: String) {
        if newTitle != task.title {
            task.title = newTitle
        }

        if newNote != task.note {
            task.note = newNote
        }
        
        saveContext()
    }

    func delete(task: ToDoTask) {
        context.delete(task)
        saveContext()
    }

    func switchStatus(of task: ToDoTask) {
        task.isComplete.toggle()
        saveContext()
    }
}

// MARK: TaskList's methods
extension StorageManager {
    func createTaskList(with title: String, completion: (ToDoTaskList) -> ()) {
        let taskList = ToDoTaskList(context: context)
        taskList.title = title
        taskList.date = Date()

        completion(taskList)
        saveContext()
    }

    func update(taskList: ToDoTaskList, with newTitle: String) {
        taskList.title = newTitle
        saveContext()
    }

    func delete(taskList: ToDoTaskList) {
        clear(taskList)
        context.delete(taskList)
        saveContext()
    }

    func clear(_ taskList : ToDoTaskList) {
        taskList.tasks?.forEach { context.delete($0 as! ToDoTask) }
        saveContext()
    }

    func switchStatus(of taskList: ToDoTaskList) {
        taskList.tasks?.forEach { ($0 as! ToDoTask).isComplete = true }
        saveContext()
    }
}

// MARK: Preview/Reset CD
extension StorageManager {
    func createPreviewTaskList() {
        var tasks: [ToDoTask] = []
        for _ in 0...5 {
            let task = ToDoTask(context: context)
            task.title = "Превью задача"
            task.date = Date()
            task.isComplete = false
            task.note = "Превью заметка"
            tasks.append(task)
        }

        let _: ToDoTaskList = {
            let list = ToDoTaskList(context: context)
            list.title = "Превью список"
            list.date = Date()

            list.addToTasks(NSOrderedSet(array: tasks))

            return list
        }()
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
