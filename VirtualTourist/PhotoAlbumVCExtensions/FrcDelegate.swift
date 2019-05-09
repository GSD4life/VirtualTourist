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
            
            self.collectionView.insertItems(at: insertedIndexPaths)
            
            self.collectionView.deleteItems(at: deletedIndexPaths)
            
            self.collectionView.reloadItems(at: updatedIndexPaths)
            
            }, completion: nil)
        
    }
    
}

