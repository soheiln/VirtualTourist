//
//  ViewController.swift
//  VirtualTourist
//
//  Created by soheiln on 5/11/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }


    // initializes ViewController
    func initView() {
        mapView.delegate = self
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
        pin.photos = [Photo]()
        showActivityIndicator()
        
        // TODO: implement a way to load "new" photos by either using a random page or keeping track of page number
        // load new photos from Flickr
        let lat = Double(pin.latitude)
        let lon = Double(pin.longitude)
        FlickrClient.getPhotosNearLocation(callerViewController: self, latitude: lat, longitude: lon, errorHandler: nil, completionHandler: {photos in
            
            // Perform on main thread
            dispatch_async(dispatch_get_main_queue()) {
                
                // photos are available
                pin.photos = photos
                self.saveAllData()
                self.hideActivityIndicator()
                self.showPhotosInCollectionViewForPin(pin)
                
            }

        })

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
        let lat = getCameraCenterLatitude()
        let lon = getCameraCenterLongitude()
        let pin = Pin()
        pin.latitude = lat
        pin.longitude = lon
        dropPinAtCoordinate(lat, longitude: lon)
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

