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
    static func getPhotosNearLocation(callerViewController vc: UIViewController, latitude: Double, longitude: Double, page_number: Int?, errorHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?, completionHandler: (NSData -> Void) ) {
        
        // Configure HTTP request
        let url = NSURL(string: Constants.flickerAPI.serviceURL + "&api_key=" + Constants.flickerAPI.Key + "&lat=" + String(latitude) + "&lon=" + String(longitude))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // Handle error
            guard (error == nil) else {
                dispatch_async(dispatch_get_main_queue()) {
                    UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos: \(error)")
                }
                return
            }
            
            // handle status code other than 2XX
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                dispatch_async(dispatch_get_main_queue()) {
                    UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. Non-2XX response from server.")
                }
                return
            }
            
            // handle empty data
            guard let _ = data else {
                dispatch_async(dispatch_get_main_queue()) {
                    UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. No response data from server")
                }
                return
            }

            var data = NSMutableData(data: data!)
            
            // remove the jsonp method from json response
            data =  NSMutableData(data: data.subdataWithRange(NSMakeRange(14, data.length - 15)))

            // Request succeeded, proceed to parse data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    UIUtilities.showAlret(callerViewController: vc, message: "Failed to get nearby photos. Could not parse response.")
                }
                return
            }

            // If page_number parameter was not provided as input, extract a valid random page number and retreive that for processing
            if page_number == nil {
                let random_page = getRandomPage(parsedResult)
                
                // case when no photos are available
                if random_page == -1 {
                    dispatch_async(dispatch_get_main_queue()) {
                        UIUtilities.showAlret(callerViewController: vc, message: "No photos available for this location.")
                        (vc as! ViewController).hideActivityIndicator()
                    }
                    return
                }
                
                // random page selected, retrieve the random page
                getPhotosNearLocation(callerViewController: vc, latitude: latitude, longitude: longitude, page_number: random_page, errorHandler: errorHandler, completionHandler: completionHandler)
                return
            }
            
            
            getPhotosFromThisPage(callerViewController: vc, json: parsedResult, num_photos: Constants.num_photos_in_new_collection, completionHandler: completionHandler)
            
        }

        task.resume()
        
    }
    
    
    // method that requests a random page from Flickr server and downloads relevant photos in that page
    static func getRandomPage(json: AnyObject) -> Int {
        
        let results = json as! [String: AnyObject]
        let result = results["photos"] as! [String: AnyObject]
        let pages = result["pages"] as! Int
        if pages == 0 { // the case when no photos are available
            return -1
        } else {
            let random_page = random() % pages + 1
            return random_page
        }
    }
    
    
    // method that takes a Flickr json response and selects num_photos number of random photos from the list
    // and calls the completion handler on each NSData response
    static func getPhotosFromThisPage(callerViewController vc: UIViewController, json: AnyObject, num_photos: Int, completionHandler: (NSData -> Void)) {
        let results = json as! [String: AnyObject]
        let result = results["photos"] as! [String: AnyObject]
        let photos = result["photo"] as! [[String: AnyObject]]
        let n_photos_avail = photos.count
        
        // loop to download num_photos number of photos
        var count = 0
        var selected = [Int]()
        let n = min(n_photos_avail, num_photos) // for the case where less than num_photos is avail in page
        while count < n {
            let rand = random() % photos.count
            if selected.contains(rand) {
                continue
            } else {
                selected.append(rand)
                count = count + 1
                var photo = photos[rand]
                let id = photo["id"] as! String
                let farm_id = photo["farm"] as! Int
                let server_id = photo["server"] as! String
                let secret = photo["secret"] as! String
                
                let url_string = "https://farm" + String(farm_id) + ".staticflickr.com/" + String(server_id) + "/" + id + "_" + secret + ".jpg"
                let url = NSURL(string: url_string)!
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "GET"
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    
                    // handle errors
                    guard (error == nil) else {
                        dispatch_async(dispatch_get_main_queue()) {
                            UIUtilities.showAlret(callerViewController: vc, message: "Error loading photos from the server.")
                            (vc as! ViewController).hideActivityIndicator()
                        }

                        return
                    }
                    
                    // handle data
                    completionHandler(data!)
                }
                task.resume()
            }
        }

        

    }
}