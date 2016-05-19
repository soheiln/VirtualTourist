//
//  UIUtilities.swift
//  VirtualTourist
//
//  Created by soheiln on 5/13/16.
//  Copyright © 2016 soheiln. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class UIUtilities {
    
    // shows alert with message and "OK" action
    static func showAlret(callerViewController vc: UIViewController, message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        vc.presentViewController(alert, animated: true, completion: nil)
        (vc as! ViewController).hideActivityIndicator()
    }
    
}
