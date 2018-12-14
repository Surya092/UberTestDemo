//
//  Constant.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import Foundation

public struct Constant {
    
    //Set API EndPoint
    enum apiEndPoint: String {
        case searchApiEndPoint = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&format=json&nojsoncallback=1&safe_search=1&page=%@&text=%@"
        case photoApiEndPoint = "https://farm%@.static.flickr.com/%@/%@_%@.jpg"
    }
    
    enum UserData: String {
        case apikey = "3e7cc266ae2b0e0d78e279ce8e361736&"
    }
    
    struct HomeCell {
        static let PhotoCollectionViewCellIdentifier = "PhotoCollectionViewCell"
        static let PhotoCollectionSectionFooterIdentifier = "PhotoCollectionSectionFooterCollectionReusableView"
    }
    
    enum APIStatus: String {
        case success = "success"
    }
    
    enum AppStringConstant: String {
        case searchMessage = "Find Something"
        case apiErrorMessage  = "Something Went Wrong"
        case noResultsMessage  = "No results Found"
    }
}
