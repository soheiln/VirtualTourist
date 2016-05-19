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

class ViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {

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

    //TODO: remove
    @IBOutlet weak var dummyImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
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
        //TODO
    }
    
    // Loads camera location
    func loadCamera() {
        //TODO
    }
    
    
    // Updates map per camera settings and shows pins on the map
    func updateMap() {
        //TODO
    }
    
    // Drops a pin at given coordinate
    func dropPinAtCoordinate(latitude: Double, longitude: Double) {
        //TODO
    }
    
    
    // Saves all data in persistent memory
    func saveAllData() {
        //TODO
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    // Loads the collection view with photos from the provided pin object
    func showPhotosInCollectionViewForPin(pin: Pin) {
        CoreDataStackManager.sharedInstance().currentPin = pin
        //TODO
    }
    
    
    // Removes the photo from pin object and adjusts the collection view accordingly and saves the final state
    func removePhoto(photo: Photo) {

        //TODO: check implementation ***
        let pin = CoreDataStackManager.sharedInstance().currentPin
        pin.removePhoto(photo)
        saveAllData()
        showPhotosInCollectionViewForPin(pin)
        
    }
    
    
    // Load a new set of photos for Pin, save the final state, and show the updated photo collection in the view
    func getNewCollectionForPin(pin: Pin) {
        //TODO: check implementation ***
        
        // clear existing photos
        pin.photos = NSSet()
        showActivityIndicator()
        
        // TODO: implement a way to load "new" photos by either using a random page or keeping track of page number
        // load new photos from Flickr
        let lat = Double(pin.latitude)
        let lon = Double(pin.longitude)
        FlickrClient.getPhotosNearLocation(callerViewController: self, latitude: lat, longitude: lon, page_number: nil, errorHandler: nil, completionHandler: {data in
            
            // Perform on main thread
            dispatch_async(dispatch_get_main_queue()) {
                
                // photos are available
                var photo = Photo(context: self.context)
                photo.pin = pin
                photo.image = data
                var photos = pin.photos.allObjects
                photos.append(photo)
                pin.photos = NSSet(array: photos)
                self.dummyImageView.image = UIImage(data: data)
                
                self.saveAllData()
                self.hideActivityIndicator()
                self.showPhotosInCollectionViewForPin(pin)
                
            }

        })

    }
    
    // MARK: - Map View Pin Drop Functionality
    
    // initializes map: sets long press handler for dropping pins
    func setLongPressHandlerForMapView() {
        lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 2.0
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
    }
    
    // handles long press on map to drop pin
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        //TODO: code refactor
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        
        // Create Pin object
        let pin = Pin(context: context)
        pin.latitude = NSNumber(double: touchMapCoordinate.latitude)
        pin.longitude = NSNumber(double: touchMapCoordinate.longitude)
        getNewCollectionForPin(pin)
        
    }
    
    // map view delegate function implementation to animate pin drop
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinAnnotationView.animatesDrop = true
        return pinAnnotationView
    }

    
    
    // Saves camera location in persistent memory
    func saveCameraLocation() {
        //TODO: check implementation ***
        
        let camera = CoreDataStackManager.sharedInstance().camera
        camera.centerLatitude = getCameraCenterLatitude()
        camera.centerLongitude = getCameraCenterLatitude()
        camera.minX = mapView.bounds.minX
        camera.minY = mapView.bounds.minY
        camera.maxX = mapView.bounds.maxX
        camera.maxY = mapView.bounds.maxY
        
        // Save data
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    
    // TODO: remove below line after use
    // ----------------------------------------------
    
    // this is to test showPhotoView() functionality
    @IBOutlet weak var dummyButton: UIButton!
    
    @IBAction func dummyButtonPressed(sender: AnyObject) {
        let lat = NSNumber(double: getCameraCenterLatitude())
        let lon = NSNumber(double: getCameraCenterLongitude())
        let pin = Pin()
        pin.latitude = lat
        pin.longitude = lon
        dropPinAtCoordinate(getCameraCenterLatitude(), longitude: getCameraCenterLongitude())
        getNewCollectionForPin(pin)
        
    }
    
    
    // gets camera's center latitude
    func getCameraCenterLatitude() -> Double {
        return mapView.centerCoordinate.latitude
    }
    
    // gets camera's center longitude
    func getCameraCenterLongitude() -> Double {
        return mapView.centerCoordinate.longitude
    }
    
    
}


// MARK: Extension - Code related to Collection View
extension ViewController {
    
    // Initializes collection view
    func initCollectionView() {
        
        let space: CGFloat = 3.0
        let numSection = 3.0
        let dimension = min((collectionView.frame.size.width - (CGFloat(numSection-1) * space)) / CGFloat(numSection),
            (collectionView.frame.size.height - (CGFloat(numSection-1) * space)) / CGFloat(numSection))
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)

    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //TODO
        if let currentPin = CoreDataStackManager.sharedInstance().currentPin {
            return CoreDataStackManager.sharedInstance().currentPin.photos.count
        }
        return 0
    }

    
    // MARK: UICollectionViewDataSource Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //TODO:
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = CoreDataStackManager.sharedInstance().currentPin.photos.allObjects[indexPath.row] as! Photo
        cell.imageView.image = UIImage(data: photo.image!)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO
        let pin = CoreDataStackManager.sharedInstance().currentPin
        let photo = pin.photos.allObjects[indexPath.row] as! Photo
        removePhoto(photo)
    }
}
