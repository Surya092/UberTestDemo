//
//  NetworkManager.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager: NSObject {
    
    private var networkSession: URLSession?
    private var networkDataTask: URLSessionDataTask?
    
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var completionHandlerImageUpload :((Data?, URLResponse?, Error?) -> Swift.Void)?
    private var responsesDataImageUpload : [Int:Data] = [:]
    
    private func getSharedConfiguration() -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 30.0
        sessionConfiguration.timeoutIntervalForResource = 30.0
        return sessionConfiguration
    }
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func cancelTask() {
        self.endBackgroundTask()
        self.networkDataTask?.cancel()
    }
    
    //Use this for Post request
    public func postData(withParameters requestData:[String: Any], cachePolicy : URLRequest.CachePolicy = .useProtocolCachePolicy, apiEndpoint apiURL: String, isurlEncoded urlencoded: Bool = false, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        self.makeServerRequest(requestType: String.kPost, cachePolicy : cachePolicy, withData: requestData,  apiEndpoint: apiURL, urlencoded: urlencoded, CompletionHandler: completionHandler)
    }
    
    //Use this for put request
    public func putData(withParameters requestData:[String: Any], cachePolicy : URLRequest.CachePolicy = .useProtocolCachePolicy, apiEndpoint apiURL: String, isurlEncoded urlencoded: Bool = false, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        self.makeServerRequest(requestType: String.kPut, cachePolicy : cachePolicy, withData: requestData, apiEndpoint: apiURL, urlencoded: urlencoded, CompletionHandler: completionHandler)
    }
    
    //Use this for get request
    public func getData(withApiEndpoint apiURL: String, cachePolicy : URLRequest.CachePolicy = .useProtocolCachePolicy, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        self.makeServerRequest(requestType: String.kGet, cachePolicy : cachePolicy, apiEndpoint: apiURL, CompletionHandler: completionHandler)
    }
    
    private func makeServerRequest(requestType rType:String, cachePolicy : URLRequest.CachePolicy = .useProtocolCachePolicy, withData requestData:[String: Any]? = nil, apiEndpoint apiURL: String, parameters:[String: String]? = nil, urlencoded:Bool = false, CompletionHandler completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        
        //Set request EndPoint and type
        var request = URLRequest(url: URL(string: apiURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        request.cachePolicy = cachePolicy
        request.httpMethod = rType
        
        //Set request headers
        if let headerParameters = parameters {
            for (key, value) in headerParameters {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        //Create a temp string to set body type in String
        var paramString: String?
        
        //Create JSON String or URLEncoded String
        if let requestDataParameters = requestData as? [String:String], urlencoded {
            var parameterArray = [String]()
            for (key, value) in requestDataParameters {
                let keyValuePair = String(format:"%@=%@", key, value)
                parameterArray.append(keyValuePair)
            }
            paramString = parameterArray.joined(separator: "&")
        } else {
            if let dataParameters = requestData {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dataParameters, options: [])
                    paramString = String(data: jsonData, encoding: .utf8)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        //Append Body Created to request
        if let parameterString = paramString, !parameterString.isEmpty {
            request.httpBody = parameterString.data(using: .utf8)
        }
        
        //Check if session is nil and set configuration
        if self.networkSession == nil {
            self.networkSession = URLSession(configuration: getSharedConfiguration())
        }
        
        debugPrint("Making \(rType) request with endpoint: \(apiURL)")
        
        self.networkDataTask = self.networkSession?.dataTask(with: request as URLRequest) { (data, response, error) in
            completionHandler(data, response, error)
            self.endBackgroundTask()
        }
        
        self.networkDataTask?.resume()
        registerBackgroundTask()
        
    }
}
