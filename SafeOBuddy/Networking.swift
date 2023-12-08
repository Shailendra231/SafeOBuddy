//
//  HttpUtility.swift
//  safeobuddyttlock
//
//  Created by Never Mind on 01/12/23.
//

import Foundation

struct Networking
{
     func callingGetAPI(url:String?, complition: @escaping(_ respponse: String?, _ message: String?, _ statusCode: String?)->Void)
    {
       
        // Specify the url for get request
        guard let url = URL(string: url!) else {
            complition(nil,"Invalid URL", "404")
            return
        }
        
        // Create an url session
        let session = URLSession.shared
        
        let tast = session.dataTask(with: url) { data, response, error in
            
            // Check for errors
            if let error = error
            {
                complition("error","\(error.localizedDescription)", "100")
                return
            }
            
            
            if let resultString = String(data: data!, encoding: .utf8)
            {
                print("Response: \(resultString)")
                complition("\(resultString)","success", "106")
            }
        }
        
        tast.resume()
    }
    
    
    
    func callingPostAPI(url:String?, parameter:[String:Any], complition: @escaping(_ respponse: String, _ message: String, _ statusCode: String) ->Void)
    {
        
        // Specify the url for get request
        guard let url = URL(string: url!) else {
            complition("","Invalid URL", "404")
            return
        }
        
        // Create a URLRequest with the specified URL
        var request = URLRequest(url: url)

        // Set the HTTP method to POST
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: []) else {return}
        
        // Set the request body data (if any)
        request.httpBody = httpBody
        
        request.timeoutInterval = 20
                
        // Create an url session
        let session = URLSession.shared
        
        let tast = session.dataTask(with: request) { data, response, error in
            
            // Check for errors
            if let error = error
            {
                complition("error","\(error.localizedDescription)", "100")
                return
            }
           
            
            if let resultString = String(data: data!, encoding: .utf8)
            {
                print("Response: \(resultString)")
                complition("\(resultString)","success", "106")
            }
        }
        
        tast.resume()
    }
    
}
