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
        

        // Configure HTTP request
        let url = NSURL(string: Constants.flickerAPI.serviceURL + "&api_key=" + Constants.flickerAPI.Key + "&lat=" + String(latitude) + "&lon=" + String(longitude) + "&format=rest")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // Handle error
            guard (error == nil) else {
                UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos: \(error)")
                return
            }
            
            // handle status code other than 2XX
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. Non-2XX response from server.")
                return
            }
            
            // handle empty data
            guard let data = data else {
                UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. No response data from server")
                return
            }
            
            
            // Request succeeded, proceed to parse data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. Could not parse JSON response.")
                return
            }

            // Extract data from JSON response
            // TODO:
            var photos = [Photo]()
            
            // Success, call completion handler
            completionHandler(photos)

            
        }

        task.resume()
        
    }
}