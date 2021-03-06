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
        // property observer
        didSet{
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
        CoreDataStackManager.sharedInstance().autoSave(Constants.autoSaveDelayInSeconds, completionHandler: {
            self.saveCameraLocation()
        })
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
        // deselect current pin annotation
        let currentAnnotation = CoreDataStackManager.sharedInstance().currentAnnotation
        CoreDataStackManager.sharedInstance().currentAnnotation = nil
        mapView.deselectAnnotation(currentAnnotation, animated: false)
        print("currnet annotation deselected: \(currentAnnotation)")
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
        saveCameraLocation()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Loads the collection view with photos from the provided pin object
    func showPhotosInCollectionViewForPin(pin: Pin) {
        CoreDataStackManager.sharedInstance().currentPin = pin
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "image", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Load a new set of photos for Pin, save the final state, and show the updated photo collection in the view
    func getNewCollectionForPin(pin: Pin) {
        // delete existing photos
        for setItem in pin.photos {
            let photo = setItem as! Photo
            context.deleteObject(photo)
        }

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
        // get touch coordinates on map
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

        // create Pin object
        let pin = Pin(context: context)
        pin.latitude = NSNumber(double: touchMapCoordinate.latitude)
        pin.longitude = NSNumber(double: touchMapCoordinate.longitude)

        // add pin on map
        let annotation = PinAnnotation()
        annotation.coordinate = touchMapCoordinate
        annotation.pin = pin
        CoreDataStackManager.sharedInstance().currentAnnotation = annotation
        mapView.addAnnotation(annotation)
        
        CoreDataStackManager.sharedInstance().currentPin = pin
        CoreDataStackManager.sharedInstance().currentAnnotation = annotation
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
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let space: CGFloat = CGFloat(Constants.CollectionView.SpaceBetweenSections)
        let numSection = Constants.CollectionView.NumSectionsInPortraitMode
        let dimension = (screenWidth - (CGFloat(numSection-1) * space)) / CGFloat(numSection)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
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
        do {
            try fetchedResultsController.performFetch()
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
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
        let photo = photos[indexPath.row]
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
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
//        print("Annotation: \(annotation)")
//        pinAnnotationView.animatesDrop = true
//        if let currentAnnotation = CoreDataStackManager.sharedInstance().currentAnnotation {
//            if (annotation as! PinAnnotation) == currentAnnotation {
//                pinAnnotationView.pinTintColor = UIColor.greenColor()
//            }
//            
//        }
//        
//        return pinAnnotationView
//    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        CoreDataStackManager.sharedInstance().currentAnnotation = nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pinAnnotation = view.annotation as! PinAnnotation
        mapView.deselectAnnotation(pinAnnotation, animated: false)
        CoreDataStackManager.sharedInstance().currentAnnotation = pinAnnotation
        let pin = pinAnnotation.pin
        showPhotoViewForPin(pin)        
    }
    
}