//
//  PersistenceController.swift
//  LymCar
//
//  Created by 이은재 on 1/5/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FavoriteModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unsolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unsolved error \(error), \(error.userInfo)")
            }
        }
    }
    
}
