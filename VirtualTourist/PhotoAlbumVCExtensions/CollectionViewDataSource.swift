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
        
        let sections = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)
            as? PhotoCollectionViewCell else { fatalError("The wrong cell was made available")}
        
        convertUrlToDisplayData(cell, indexPath)
        
        return cell
        
    }
}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.

