//
//  CollectionViewDataSource.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 5/9/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import UIKit

extension PhotoAlbumVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        print("number of sections: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("cellForItemAt called")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)
            as! PhotoCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        
        let cellPhotoImage = fetchedResultsController.object(at: indexPath)
        
        guard let cellURL = cellPhotoImage.imageURL else { return cell }
        assert(cellURL == cellPhotoImage.imageURL, "CellURL error, line 209")
        
        guard let url = URL(string: cellURL) else { return cell }
        assert(url == URL(string: cellURL), "Url error within CellForItemAt, line 211")
        
        performUIUpdatesOnMain {
            cell.activityViewIndicator.startAnimating()
            cell.activityViewIndicator.hidesWhenStopped = true
        }
        
        DispatchQueue.global(qos: .background).async {
            
            FlickrClient.sharedInstance().downloadImages(url) { [weak self] (data, error) in
                guard (error == nil) else { return }
                assert(error == nil, "FlickrClient download images issue, line 220")
                if let data = data {
                    performUIUpdatesOnMain {
                        cellPhotoImage.image = data
                        guard let cellImage = cellPhotoImage.image else { return }
                        cellPhotoImage.pin = self?.pin
                        guard let _ = try? self?.dataController.viewContext.save() else { return }
                        cell.virtualTouristImageView.image = UIImage(data: cellImage)
                        cell.setNeedsLayout()
                        cell.activityViewIndicator.stopAnimating()
                    }
                }
            }
        }
        
        return cell
        
    }
}
