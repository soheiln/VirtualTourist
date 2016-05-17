//
//  Pin.swift
//  VirtualTourist
//
//  Created by soheiln on 5/13/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    
    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    @NSManaged var photos: [Photo]!
    
    
    // Removes a photo from the photos collection of this pin
    func removePhoto(photo: Photo) {
        //TODO
    }
    
}
