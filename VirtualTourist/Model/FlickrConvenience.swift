//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/7/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotos(_ latitude: Double, _ longitude: Double, _ completionHandlerForPhotos: @escaping (_ success: Bool, _ array: [URL]?, _ error: NSError?) -> Void ) {
        
        let latitude = latitude
        let longitude = longitude
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Latitude: latitude,
            Constants.FlickrParameterKeys.Longitude: longitude,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude),
            Constants.FlickrParameterKeys.Page: Constants.FlickrParameterValues.ResponsePerPage
            ] as [String:AnyObject]
        
        
         let _ = taskForGet(parameters: methodParameters) { (data, error) in
            func displayError(_ error: String) {
                print(error)
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error?.localizedDescription ?? "Api error")")
                completionHandlerForPhotos(false, nil, error)
                return
            }
            
            if let data = data {
                guard let stat = data[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    displayError("Flickr API returned an error. See error code and message in \(data)")
                    return
                }
            
                
                guard let photosDictionary = data[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                    displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(data)")
                    return
                }
                
                
                guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                    return
                }
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                var arrayOfURLs: [URL] = []
                for photo in photosArray {
                    guard let imageUrlString = URL(string: photo[Constants.FlickrResponseKeys.MediumURL] as? String ?? "No URL found") else {displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)")
                        return}
                    arrayOfURLs.append(imageUrlString)
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let _ = photosArray[randomPhotoIndex] as [String: AnyObject]
                    
                }
                completionHandlerForPhotos(true, arrayOfURLs, nil)
            }
        }
    }
    
    private func bboxString(_ latitude: Double, _ longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}
