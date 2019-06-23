//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/14/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}

// Sources:
// Udacity IOS program, Udacity forums, and mentors.
