//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/7/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import UIKit

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
            Constants.FlickrParameterKeys.PhotosPerPage: Constants.FlickrParameterValues.ResponsePerPage,
            Constants.FlickrParameterKeys.Page: randomPageNumber
        ] as [String:AnyObject]
        
        
        let _ = taskForGet(parameters: methodParameters) { [weak self] (data, error) in
            func displayError(_ error: String) {
                print(error)
            }
            
            guard (error == nil) else {
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
                
                // replaced totalPages with _
                guard let _ = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
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
                    self?.imageString = imageUrlString
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    self?.randomPageNumber = randomPhotoIndex
                    let _ = photosArray[randomPhotoIndex] as [String: AnyObject]
                    
                }
                completionHandlerForPhotos(true, arrayOfURLs, nil)
            }
        }
    }
    
    func downloadImages(_ url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let urlRequest = URLRequest(url: url)
        
        func displayError(_ message: String) {
            print(message)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard (error == nil) else {
                displayError("The url request generated this error: \(error?.localizedDescription ?? "download image error")")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                displayError("there was an error getting the data")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            completion(data, nil)
        }
        
        task.resume()
    }
    
    func convertFlickrUrlIntoData(_ url: URL) -> Data? {
        guard let urlToData = try? Data(contentsOf: url) else {
            print("unable to convert URL to data")
            return nil
        }
        return urlToData
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

// Sources:
// Udacity IOS program (including Udacity GitHub colorCollection), Udacity forums, and mentors.
