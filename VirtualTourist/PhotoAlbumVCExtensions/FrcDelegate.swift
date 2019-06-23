//
//  FrcDelegate.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 5/9/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import CoreData

extension PhotoAlbumVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("controller didChange anObject reached")
        guard let newPath = newIndexPath else { return }
        guard let path = indexPath else { return }
        
        switch type {
            
        case .insert:
            print("Insert an item")
            insertedIndexPaths.append(newPath)
            break
            
        case .delete:
            print("Delete an item")
            deletedIndexPaths.append(path)
            break
            
        case .update:
            print("update an item")
            updatedIndexPaths.append(path)
            break
            
        case .move:
            break
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        
        deletedIndexPaths.forEach({ (indexPath) in
            collectionView.deleteItems(at: [indexPath])
        })
        
        insertedIndexPaths.forEach({ (indexPath) in
            collectionView.insertItems(at: [indexPath])
        })
        
//        updatedIndexPaths.forEach({ (indexPath) in
//            collectionView.reloadItems(at: [indexPath])
//        })
        
    }
    
    
}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.

