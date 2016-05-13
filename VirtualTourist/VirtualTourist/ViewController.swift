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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }


    // initializes ViewController
    func initView() {
        mapView.delegate = self
        hidePhotoView()
    }

    
    // hides all Photos overlay view elements
    func hidePhotoView() {
        navigationBar.hidden = true
        tabBar.hidden = true
        collectionView.hidden = true
        newCollectionButton.hidden = true
    }
    
    // shows all Photos overlay view elements
    func showPhotoView() {
        navigationBar.hidden = false
        tabBar.hidden = false
        collectionView.hidden = false
        newCollectionButton.hidden = false
    }
    
    
    @IBAction func OKButtonPressed(sender: AnyObject) {
        hidePhotoView()
    }
    
    
    // TODO: remove after use
    // this is to test showPhotoView() functionality
    @IBOutlet weak var dummyButton: UIButton!
    @IBAction func dummyButtonPressed(sender: AnyObject) {
        showPhotoView()
    }
    
    
    
}

