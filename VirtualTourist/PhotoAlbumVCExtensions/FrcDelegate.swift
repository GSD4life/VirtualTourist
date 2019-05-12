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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("didChange sectionInfo reached")
        
        switch type {
        
        case .insert:
            collectionView.insertSections(IndexSet(integer: sectionIndex))
            break
        case .delete:
            collectionView.deleteSections(IndexSet(integer: sectionIndex))
            break;
        default:
            break
        }
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent reached")
        
        // performBatchUpdates - allows multiple insert/delete/reload/move calls to be animated simultaneously.
        let blockOperations = BlockOperation()
        
        blockOperations.addExecutionBlock { [unowned self] in
            
            // performBatchUpdates - allows multiple insert/delete/reload/move calls to be animated simultaneously.
            self.collectionView.performBatchUpdates({ [unowned self] () -> Void in
                
                self.collectionView.insertItems(at: self.insertedIndexPaths)
                
                self.collectionView.deleteItems(at: self.deletedIndexPaths)
                
                self.collectionView.reloadItems(at: self.updatedIndexPaths)
                
                
                }, completion: nil
            )}
        
    }
}
