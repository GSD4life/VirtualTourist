//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Shane Sealy on 2/7/19.
//  Copyright © 2019 Shane Sealy. All rights reserved.
//

import UIKit

class FlickrClient {
    
    func taskForGet(parameters: [String:AnyObject], completionHandlerForGet: @escaping (_ success: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        let flickrURL = flickrURLFromParameters(parameters)
        let request = URLRequest(url: flickrURL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(nil, NSError(domain: "taskForGet", code: 1, userInfo: userInfo))
            }
           
            guard (error == nil) else {
                sendError("There was an error with your request: \(error?.localizedDescription ?? "Unable to get data")")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            self.convertDataWithCompletionHandler(data, completionHandlerForGet)
            
        }
        
        task.resume()
        
        return task
        
    }
    
    
    // Mark: Helper function
    private func convertDataWithCompletionHandler(_ data: Data, _ completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    // Mark: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
}
