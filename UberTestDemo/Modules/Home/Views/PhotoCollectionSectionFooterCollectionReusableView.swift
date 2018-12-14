//
//  PhotoCollectionSectionFooterCollectionReusableView.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 14/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import UIKit

class PhotoCollectionSectionFooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var loaderIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func stopAnimating() {
        loaderIndicatorView.stopAnimating()
        loaderIndicatorView.isHidden = true
        textLabel.isHidden = false
    }
    
    func startAnimating() {
        loaderIndicatorView.startAnimating()
        loaderIndicatorView.isHidden = false
        textLabel.isHidden = true
    }
}
