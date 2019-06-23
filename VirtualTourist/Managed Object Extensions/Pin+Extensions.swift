//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/14/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.

