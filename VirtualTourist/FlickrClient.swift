//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by soheiln on 5/16/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    // static method that takes callerVC, latitude, and longitude and gets a set of photos near that coordinate
    static func getPhotosNearLocation(callerViewController vc: UIViewController, latitude: Double, longitude: Double, errorHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?, completionHandler: ([Photo] -> Void) ) {
        
    }
}