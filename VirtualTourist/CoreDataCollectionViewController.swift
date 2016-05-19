//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by soheiln on 5/19/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataCollectionViewController: UICollectionViewController {
    
    // MARK - Properties
    var fetchedResultsController: NSFetchedResultsController {
        didSet{
            // whenever the frc changes, we execute the search and reload the collection view
            executeSearch()
            collectionView
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}