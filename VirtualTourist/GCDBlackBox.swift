//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 3/4/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

// Sources:
// Udacity IOS program, Udacity forums, and mentors.
