//
//  Constants.swift
//  VirtualTourist
//
//  Created by soheiln on 5/16/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation

struct Constants {
    struct flickerAPI {
        static let Key = "b675d743dceec133b1eb0011e8bdfcbb"
        static let Secrect = "580e9683a5a2a2db"
        static let serviceURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json"
    }
    
    struct CollectionView {
        static let NumSectionsInPortraitMode = 3.0
        static let NumSectionsInLandscapeMode = 6.0
        static let SpaceBetweenSections = 3.0
    }
    static let num_photos_in_new_collection = 16
    static let MinimumPressDuration = 1.0
    
    
}