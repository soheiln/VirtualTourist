//
//  ViewController.swift
//  VirtualTourist
//
//  Created by soheiln on 5/11/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var lpgr: UILongPressGestureRecognizer!
    var context: NSManagedObjectContext!

    var fetchedResultsController : NSFetchedResultsController! {
        didSet{
            //TODO:remove
            print("in frc didSet")
            // Whenever the frc changes, we execute the search and reload the table
            executeSearch()
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }

    
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        let pin = CoreDataStackManager.sharedInstance().currentPin
        getNewCollectionForPin(pin)
    }

    // initializes ViewController
    func initView() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        context = CoreDataStackManager.sharedInstance().managedObjectContext
        setLongPressHandlerForMapView()
        initCollectionView()
        hidePhotoView()
        hideActivityIndicator()
        loadData()
        updateMap()
    }

    
    // hides all Photos overlay view elements
    func hidePhotoView() {
        navigationBar.hidden = true
        tabBar.hidden = true
        collectionView.hidden = true
        newCollectionButton.hidden = true
        
        // clear currentPin
        CoreDataStackManager.sharedInstance().currentPin = nil
    }
    
    // shows all Photos overlay view elements
    func showPhotoView() {
        navigationBar.hidden = false
        tabBar.hidden = false
        collectionView.hidden = false
        newCollectionButton.hidden = false
    }
    
    // shows the photo view for the provided pin object - used for pins with already loaded photos
    func showPhotoViewForPin(pin: Pin) {
        CoreDataStackManager.sharedInstance().currentPin = pin
        showPhotoView()
        showPhotosInCollectionViewForPin(pin)
        collectionView.reloadData()
    }
    
    @IBAction func OKButtonPressed(sender: AnyObject) {
        saveAllData()
        hidePhotoView()
    }
    
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    
    func hideActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    
    // Loads all pins and camera data
    func loadData() {
        loadCamera()
        loadPins()
    }
    
    // Loads all pins from persistent memory
    func loadPins() {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fc.performFetch()
            CoreDataStackManager.sharedInstance().pins = fc.fetchedObjects as! [Pin]
        } catch {
            print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
        }
        
    }
    
    // Loads camera location
    func loadCamera() {
        let fetchRequest = NSFetchRequest(entityName: "Camera")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "x", ascending: false)]
        let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fc.performFetch()
            let cameras = fc.fetchedObjects as! [Camera]
            print("number of cameras found: \(cameras.count)")
            
            if cameras.count == 0 {
                // no camera object saved before
                return
            } else {
                // camera object available from before
                CoreDataStackManager.sharedInstance().camera = cameras[0]
            }
            
        } catch {
            print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
        }
    }
    
    
    // Updates map per camera settings and shows pins on the map
    func updateMap() {
        // update camera
        if let camera = CoreDataStackManager.sharedInstance().camera {
            let origin = MKMapPoint(x: camera.x as Double, y: camera.y as Double)
            let size = MKMapSize(width: camera.width as Double, height: camera.height as Double)
            let mapRect = MKMapRect(origin: origin, size: size)
            mapView.setVisibleMapRect(mapRect, animated: false)
        }
        
        // show pins on map
        let pins = CoreDataStackManager.sharedInstance().pins
        for pin in pins {
            showPinOnMap(pin)
        }
    }
    
    // Shows a single Pin object on map
    func showPinOnMap(pin: Pin) {
        let annotation = PinAnnotation()
        annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
        annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
        annotation.pin = pin
        mapView.addAnnotation(annotation)

    }
    
    // Saves all data in persistent memory
    func saveAllData() {
        saveCameraLocation() //TODO: refactor to autoSave()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    // Loads the collection view with photos from the provided pin object
    func showPhotosInCollectionViewForPin(pin: Pin) {
        //TODO: check
        CoreDataStackManager.sharedInstance().currentPin = pin
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "image", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    // Removes the photo from pin object and adjusts the collection view accordingly and saves the final state
    func removePhotoFromPin(pin: Pin, index: Int) {
        
        var photoArray = pin.photos.allObjects
        let photo = photoArray[index] as! Photo
        context.deleteObject(photo)
//        photoArray.removeAtIndex(index)
        
//        pin.photos = NSSet(array: photoArray)
        saveAllData()
        
//        pin.removePhoto(photo)
//        saveAllData()
//        showPhotosInCollectionViewForPin(pin)
        
    }
    
    
    // Load a new set of photos for Pin, save the final state, and show the updated photo collection in the view
    func getNewCollectionForPin(pin: Pin) {
        // clear existing photos
        pin.photos = NSSet()
        showActivityIndicator()
        
        // load new photos from Flickr
        let lat = Double(pin.latitude)
        let lon = Double(pin.longitude)
        FlickrClient.getPhotosNearLocation(callerViewController: self, latitude: lat, longitude: lon, page_number: nil, errorHandler: nil, completionHandler: {data in
            
            // Perform on main thread
            dispatch_async(dispatch_get_main_queue()) {
                
                // a new photos is available
                let photo = Photo(context: self.context)
                photo.pin = pin
                photo.image = data
                var photos = pin.photos.allObjects
                photos.append(photo)
                pin.photos = NSSet(array: photos)
                
                self.saveAllData()
                self.hideActivityIndicator()
                self.showPhotoViewForPin(pin)
            }

        })

    }
}

// MARK: - Map View Pin Drop Functionality
extension ViewController {
    // initializes map: sets long press handler for dropping pins
    func setLongPressHandlerForMapView() {
        lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = Constants.MinimumPressDuration
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
    }
    
    // handles long press on map to drop pin
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        // add pin on map
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = PinAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        
        // create Pin object
        let pin = Pin(context: context)
        pin.latitude = NSNumber(double: touchMapCoordinate.latitude)
        pin.longitude = NSNumber(double: touchMapCoordinate.longitude)
        getNewCollectionForPin(pin)
        
    }
    
    // Saves camera location in persistent memory
    func saveCameraLocation() {
        if CoreDataStackManager.sharedInstance().camera == nil {
            // camera object being created for the first time
            CoreDataStackManager.sharedInstance().camera = Camera(context: context)
        }
        CoreDataStackManager.sharedInstance().camera.x = mapView.visibleMapRect.origin.x
        CoreDataStackManager.sharedInstance().camera.y = mapView.visibleMapRect.origin.y
        CoreDataStackManager.sharedInstance().camera.width = mapView.visibleMapRect.size.width
        CoreDataStackManager.sharedInstance().camera.height = mapView.visibleMapRect.size.height
        CoreDataStackManager.sharedInstance().saveContext()
    }
}


// MARK: Extension - Code related to Collection View
extension ViewController {
    
    // Initializes collection view
    func initCollectionView() {
        
        collectionView.backgroundColor = UIColor.whiteColor()
        let space: CGFloat = CGFloat(Constants.CollectionView.SpaceBetweenSections)
        let numSection = Constants.CollectionView.NumSectionsInPortraitMode
        let dimension = min((collectionView.frame.size.width - (CGFloat(numSection-1) * space)) / CGFloat(numSection),
            (collectionView.frame.size.height - (CGFloat(numSection-1) * space)) / CGFloat(numSection))
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
//        print("space, numSection, dimension, frame width, frame height: \(space), \(numSection), \(dimension), \(collectionView.frame.size.width), \(collectionView.frame.size.height)")

    }
    
    
}




// MARK: - Fetched Results Controller Delegate
extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        fetchedResultsController = controller
        executeSearch()
        collectionView.reloadData()
    }
    
    func executeSearch() {
        //TODO: check
        do {
            try fetchedResultsController.performFetch()
            print("fetchedResultsController.performFetch()")
        } catch {
            print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
        }
    }

}


// MARK: - Collection View Controller Delegate and Data Source
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController == nil {
            return 0
        } else {
            return fetchedResultsController.sections![section].numberOfObjects
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        if fetchedResultsController.fetchedObjects == nil {
            print("fetchedResultsController.fetchedObjects is nil")
        }
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
//        print("photos.count: \(photos)")
        let photo = photos[indexPath.row]
//        print("indexpath.row: \(indexPath.row)")
//        print("photo: \(photo)")
//        if photo.image == nil {print("photo.image nil")}
        cell.imageView.image = UIImage(data: photo.image!)
        cell.photo = photo
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        let photo = cell.photo

        // delete photo managed object
        context.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // update fetchedResultsController and reload collectionView
        executeSearch()
        collectionView.reloadData()

    }

}


// MARK - MKMapView Delegate
extension ViewController {
    
    // map view delegate function implementation to animate pin drop
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinAnnotationView.animatesDrop = true
        return pinAnnotationView
    }
    
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("pin selected!")
        let pin = (view.annotation as! PinAnnotation).pin
        print("pin.photos.count: \(pin.photos.count)")
        showPhotoViewForPin(pin)
        
    }
    
}