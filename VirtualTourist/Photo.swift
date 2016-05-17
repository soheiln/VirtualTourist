//
//  Photo.swift
//  VirtualTourist
//
//  Created by soheiln on 5/13/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {
    @NSManaged var image: UIImage!
    @NSManaged var pin: Pin!
    
    
    convenience init(context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
        } else {
            fatalError("Could not find Entity for name: Photo")
        }
    }
}