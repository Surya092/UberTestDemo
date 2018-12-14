//
//  PhotoCollectionViewCell.swift
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    //UI References
    @IBOutlet weak var cellImageView: UIImageView!
    
    weak var homePage: HomeViewController?
    var operation: Operation?
    var apiPoint = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(model: PhotoModel) {
        if let apiRequest = homePage?.homePageRequest, let farm = model.farm, let server = model.server, let id = model.id, let secret = model.secret {
            let stringFarm = "\(farm)"
            apiPoint = String.init(format: Constant.apiEndPoint.photoApiEndPoint.rawValue, stringFarm, server, id, secret)
            let imageKey = stringFarm + server + id + secret
            
            //If image is present in cache retrieve
            if let image = apiRequest.getImageFromDocumentDirectory(key: imageKey) {
                self.cellImageView.image = image
                return
            }
            
            //Make request to Fetch Image and update the cell
            operation = BlockOperation(block: {
                apiRequest.getImage(imageAPIEndPoint: self.apiPoint, imageKey: imageKey) {[weak self] (image,imageAPIEndPoint)  in
                    if let strongSelf = self {
                        if let oper = strongSelf.operation, !oper.isCancelled, imageAPIEndPoint == strongSelf.apiPoint {
                            OperationQueue.main.addOperation({
                                strongSelf.cellImageView.image = image
                            })
                        }
                    }
                }
            })
            
            //Add Operation to Operation Queue
            if let oper = operation {
                apiRequest.concurrentQueue.addOperation(oper)
            }
        }
    }
    
    override func prepareForReuse() {
        apiPoint = ""
        cellImageView.image = nil
        operation?.cancel()
    }
}
