//
//  Camera.swift
//  VirtualTourist
//
//  Created by soheiln on 5/16/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Camera: NSManagedObject {
    @NSManaged var x: NSNumber!
    @NSManaged var y: NSNumber!
    @NSManaged var width: NSNumber!
    @NSManaged var height: NSNumber!
    
    // convenience initializer which in turn calls the designated initializer with entity and context parameters
    convenience init(context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Camera", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.x = 0.0
            self.y = 0.0
            self.width = 0.0
            self.height = 0.0
        } else {
            fatalError("Unable to find Entity name: Camera")
        }
    }

}