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
    @NSManaged var photos: NSSet!
    
    // convenience initializer which in turn calls the designated initializer with entity and context parameters
    convenience init(context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = 0.0
            self.longitude = 0.0
            self.photos = NSSet()
        } else {
            fatalError("Unable to find Entity name: Pin")
        }
    }
    
    
    // Removes a photo from the photos collection of this pin
    func removePhoto(photo: Photo) {
        //TODO
    }
    
}
