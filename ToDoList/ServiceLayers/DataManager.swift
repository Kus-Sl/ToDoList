//
//  DataManager.swift
//  ToDoList
//
//  Created by Вячеслав Кусакин on 23.07.2022.
//

import Foundation

class DataManager {

    static let shared = DataManager()

    private init() {}

    func setPreviewData() {
        if !UserDefaults.standard.bool(forKey: "Preview") {
            StorageManager.shared.createPreviewTaskList()
            DispatchQueue.main.async {
                StorageManager.shared.saveContext()
                UserDefaults.standard.set(true, forKey: "Preview")
            }
        }
    }
}
