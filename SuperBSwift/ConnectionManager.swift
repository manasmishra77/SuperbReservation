//
//  ConnectionManager.swift
//  NaurooSitters
//
//  Created by Nauroo on 4/21/15.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit
import MBProgressHUD

class ConnectionManager: NSObject
{
    class func get(_ uri: String, showProgressView: Bool = false, parameter: [String: AnyObject]?, completionHandler: @escaping (_ code: Int, _ response: AnyObject) -> ())
    {
        var newUri = uri
        //ConnectionManager.connect("GET", uri: uri, completionHandler: completionHandler)
        if parameter != nil{
            let parameterString = parameter?.stringFromHttpParameters()
            newUri = "\(uri)?\(parameterString!)"
            print(newUri)
        }
        ConnectionManager.connect("GET", uri: newUri, showProgressView: showProgressView, completionHandler: completionHandler)
    }
    
    class func post(_ uri: String, body: AnyObject, useToken: Bool = false, showProgressView: Bool = false, completionHandler: @escaping (_ code: Int, _ response: AnyObject) -> ())
    {
        //ConnectionManager.connect("POST", uri: uri, body: body, useToken: useToken, completionHandler: completionHandler)
        ConnectionManager.connect("POST", uri: uri, body: body, useToken: useToken, showProgressView: showProgressView, completionHandler: completionHandler)
    }
    
    class func delete(_ uri: String, body: AnyObject, useToken: Bool = true, showProgressView: Bool = false, completionHandler: @escaping (_ code: Int, _ response: AnyObject) -> ())
    {
        ConnectionManager.connect("DELETE", uri: uri, body: body, useToken: useToken, completionHandler: completionHandler)
        
    }
    class func put(_ uri: String, body: AnyObject, useToken: Bool = false, showProgressView: Bool = false, completionHandler: @escaping (_ code: Int, _ response: AnyObject) -> ())
    {
        ConnectionManager.connect("PUT", uri: uri, body: body, useToken: useToken, showProgressView: showProgressView, completionHandler: completionHandler)
    }
    
    class func connect(_ method: String, uri: String, body: AnyObject? = nil, useToken: Bool = true, showProgressView: Bool = false, completionHandler: @escaping (_ code: Int, _ response: AnyObject) -> ())
    {
        print("uri \(uri)")
        print(body)
        
        let uriFull = "\(apiURI)\(uri)"
        
        if let url = URL(string: uriFull)
        {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = method
            
            if (useToken)
            {
                
                if let token = UserDefaults.standard.string(forKey: "SignInToken"){
                    print(token)
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                
            }
            else
            {
                /*
                let serverAuth = "clientapp:123456"
                
                if let authData = serverAuth.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                {
                    //print(authData)
                    request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
                }
                */
            }
            
            if let body = body
            {
                if body is Data
                {
                    request.httpBody = body as? Data
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                }
                else
                {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    do
                    {
                        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
                    }
                        
                    catch
                    {
                        print("Couldn't serialize body")
                    }
                }
            }
            request.timeoutInterval = 20.0
            
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if showProgressView{
                DispatchQueue.main.async {
                    let spinnerActivity = MBProgressHUD.showAdded(to: appDel.window!, animated: true);
                    spinnerActivity.label.text = "Loading"
                    spinnerActivity.label.textColor =  UIColor.white
                    spinnerActivity.bezelView.color = UIColor.clear
                    spinnerActivity.detailsLabel.text = "Please Wait!!"
                    spinnerActivity.detailsLabel.textColor =  UIColor.white
                    spinnerActivity.isUserInteractionEnabled = false
                    
                }
            }
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
    
                if let response = response as? HTTPURLResponse
                {
                    if (response.statusCode == 500)
                    {
                        completionHandler(response.statusCode, "" as AnyObject)
                        DispatchQueue.main.async {
                            MBProgressHUD.hideAllHUDs(for: appDel.window!, animated: true)
                        }
                    
                        return
                    }
                    
                    if let headers = response.allHeaderFields as? [String: AnyObject]
                    {
                        if let contentType = headers["Content-Type"] as? String
                        {
                            //print("Content ype: \(contentType)")
                            if (contentType.contains("application/json"))
                            {
                                if let data = data
                                {
                                    do
                                    {
                                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
                                            
                                        {
                                
                                            if let responseData = jsonResponse["data"]
                                            {
                                                //print(responseData)
                                                
                                               
                                                    if let jsonDictionary = responseData as? AnyObject
                                                    {
                                                        completionHandler(response.statusCode, jsonDictionary as AnyObject)
                                                    }
                                            }
                                
                                            else
                                            {
                                                completionHandler(response.statusCode, jsonResponse["error"] as AnyObject)
                                            }
                                        }
                                }catch
                                    {
                                        print("Couldn't parse JSON response")
                                    }
                                }
                            }
                            else
                            {
                                if let data = data
                                {
                                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                                }
                                else
                                {
                                    print("No data in response: \(response)")
                                }
                            }
                        }
                        if(showProgressView){
                        DispatchQueue.main.async {
                            MBProgressHUD.hideAllHUDs(for: appDel.window!, animated: true) }
                        }
                    }
                }
                if(showProgressView){
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: appDel.window!, animated: true)
                    }}})
            task.resume()
        }
    }
    
 
    
    
}
