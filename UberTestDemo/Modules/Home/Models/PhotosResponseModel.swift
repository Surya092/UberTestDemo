//
//  PhotosResponseModel.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import Foundation

class PhotosResponseModel: NSObject {
    
    //Total Items
    var totalItems: String?
    
    //Total Number of Pages
    var totalPages: Int?
    
    //Current Page no
    var pageNumber: Int?
    
    //Item Per Page
    var itemPerPage: Int?
    
    //Photos Collection
    var photoModels: [PhotoModel]?
    
    //Search Text
    var searchText = ""
    
}
