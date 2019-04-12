//
//  DataController.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/6/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil)  {
        persistentContainer.loadPersistentStores { [unowned self] (storeDescription, error) in
            guard (error == nil) else {
                fatalError(error?.localizedDescription ?? "There was an error loading the store")
            }
            //self.autoSaveViewContext()
            completion?()
        }
        
    }
    
}
extension DataController {
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot have negative save interval")
            return
        }
        if viewContext.hasChanges {
            guard let _ = try? viewContext.save() else {
            print("unable to save viewContext changes")
            return }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    
}



