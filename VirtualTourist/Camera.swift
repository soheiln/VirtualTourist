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
    @NSManaged var centerLatitude: NSNumber!
    @NSManaged var centerLongitude: NSNumber!
    @NSManaged var minX: NSNumber!
    @NSManaged var minY: NSNumber!
    @NSManaged var maxX: NSNumber!
    @NSManaged var maxY: NSNumber!
    
}