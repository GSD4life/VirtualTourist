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
        print("controllerWillChangeContent reached")
        insertedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("controller didChange anObject reached")
        guard let newPath = newIndexPath else { return }
        guard let path = indexPath else { return }
        
        switch type {
        case .insert:
            insertedIndexPaths.append(newPath)
            break
        case .delete:
            deletedIndexPaths.append(path)
            break
        case .update:
            updatedIndexPaths.append(path)
            break
        default:
            break
        }
    }
    
    //  Causes collectionView cells to constantly update and blocks CollectionView delegate didSelectItemAt ?
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent reached")
        
        collectionView.performBatchUpdates({ [unowned self] () -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            /*  this blocks the UI and affects didSelectItemAt - removed per mentor
             //  as newCollectionButton title does not update to "Remove Selected Picture"
             for indexPath in self.updatedIndexPaths {
             self.collectionView.reloadItems(at: [indexPath])
             } */
            
            }, completion: nil)
        
    }
    
}

