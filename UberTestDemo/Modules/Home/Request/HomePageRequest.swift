//
//  HomePageRequest.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 13/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import Foundation
import UIKit

class HomePageRequest: NSObject {
    
    let networkManager = NetworkManager.init()
    let concurrentQueue = OperationQueue.init()
    var requestDictionary = [String:String]()
    
    //MARK: Fetch Search API Data
    func getSearchQueryData(searchText: String, pageNumber: String, completionHandler: @escaping (PhotosResponseModel?, Error?, Int?) -> Swift.Void) {
        let searchAPIEndPoint = String.init(format: Constant.apiEndPoint.searchApiEndPoint.rawValue, Constant.UserData.apikey.rawValue, pageNumber, searchText)
        
        if requestDictionary[searchAPIEndPoint] == nil {
            requestDictionary[searchAPIEndPoint] = searchAPIEndPoint
        } else {
            return
        }
        
        self.networkManager.cancelTask()
        self.cancelAllOperation()
        
        //Make request on Background Thread
        DispatchQueue.global().async {
            self.networkManager.getData(withApiEndpoint: searchAPIEndPoint) { (data, response, error) in
                
                self.requestDictionary[searchAPIEndPoint] = nil
                var responseStatusCode: Int?
                if let httpResponse = response as? HTTPURLResponse {
                    responseStatusCode = httpResponse.statusCode
                }
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil, error, responseStatusCode)
                    }
                } else {
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completionHandler(nil, error, responseStatusCode)
                        }
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any], let status = json["stat"] as? String, status == "ok" {
                            let responseModel = self.parseAPIresponse(jsonDictionary: json, searchText: searchText)
                            DispatchQueue.main.async {
                                completionHandler(responseModel, nil, responseStatusCode)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completionHandler(nil, error, responseStatusCode)
                            }
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            completionHandler(nil, error, responseStatusCode)
                        }
                    }
                    
                }
            }
        }
    }
    
    //MARK: Fetch Image API Data
    func getImage(imageAPIEndPoint: String, imageKey: String,completionHandler: @escaping (UIImage?, String) -> Swift.Void) {
        
        if let imageURL = URL.init(string: imageAPIEndPoint) {
            if let imageData = try? Data.init(contentsOf: imageURL), let image = UIImage.init(data: imageData)  {
                self.saveImageToDocumentDirectory(image: image, key: imageKey)
                completionHandler(image,imageAPIEndPoint)
            } else {
                completionHandler(nil,imageAPIEndPoint)
            }
        } else {
            completionHandler(nil,imageAPIEndPoint)
        }
        
    }
    
    func cancelAllOperation() {
        concurrentQueue.cancelAllOperations()
    }
    
    //MARK: Parse API response for search
    func parseAPIresponse(jsonDictionary: [String:Any],  searchText: String) -> (PhotosResponseModel) {
        let photosResponseModel = PhotosResponseModel.init()
        if let responseData = jsonDictionary["photos"] as? [String:Any] {
            
            //Number of Items in Response
            if let itemsInResponse = responseData["perpage"] as? Int {
                photosResponseModel.itemPerPage = itemsInResponse
            }
            
            //Total Number of Pages for Search Text
            if let totalPages = responseData["pages"] as? Int {
                photosResponseModel.totalPages = totalPages
            }
            
            //Current Page for Response
            if let currentPage = responseData["page"] as? Int {
                photosResponseModel.pageNumber = currentPage
            }
            
            //Total Number of Items for search text
            if let totalItemsCount = responseData["total"] as? String {
                photosResponseModel.totalItems = totalItemsCount
            }
            
            photosResponseModel.searchText = searchText
            
            //Parse Photo Model Inside the response
            if let responsePhotoModels = responseData["photo"] as? [[String:Any]] {
                var photoModels = [PhotoModel]()
                
                //Enumerate Photomodels in responses
                for model in responsePhotoModels {
                    let photomodel = PhotoModel.init()
                    
                    //Parse Farm
                    if let farm = model["farm"] as? Int {
                        photomodel.farm = farm
                    }
                    
                    //Parse Server
                    if let server = model["server"] as? String {
                        photomodel.server = server
                    }
                    
                    //Parse Secret
                    if let secret = model["secret"] as? String {
                        photomodel.secret = secret
                    }
                    
                    //Parse Id
                    if let id = model["id"] as? String {
                        photomodel.id = id
                    }
                    
                    //Append Model to DataSource
                    photoModels.append(photomodel)
                }
                
                if photoModels.count > 0 {
                    photosResponseModel.photoModels = photoModels
                }
            }
        }
        return photosResponseModel
    }
    
    //Save Image to FileManager
    func saveImageToDocumentDirectory(image: UIImage, key: String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let fileURL = documentsDirectory?.appendingPathComponent(key), let imageData = image.jpegData(compressionQuality: 0.5) {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try imageData.write(to: fileURL)
                } catch {
                    debugPrint("error saving file:", error)
                }
            }
        }
    }
    
    //Get Image from FileManager
    func getImageFromDocumentDirectory(key: String) -> (UIImage?) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(key)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            }
        }
        return nil
    }
}
