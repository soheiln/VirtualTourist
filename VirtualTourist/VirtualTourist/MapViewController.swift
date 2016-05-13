//
//  ViewController.swift
//  VirtualTourist
//
//  Created by soheiln on 5/11/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }



}

