//
//  DataController.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/6/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation
import CoreData

final class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil)  {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard (error == nil) else {
                fatalError(error?.localizedDescription ?? "There was an error loading the store")
            }
            completion?()
        }
    }
    
}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.



