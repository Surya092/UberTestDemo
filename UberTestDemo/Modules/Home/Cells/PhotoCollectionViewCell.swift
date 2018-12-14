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
            
            //If image is present in cache retrieve using Background Thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                
                if let strongSelf = self {
                    
                    if let image = apiRequest.getImageFromDocumentDirectory(key: imageKey) {
                        DispatchQueue.main.async { [weak strongSelf] in
                            if let selfInstance = strongSelf {
                                selfInstance.cellImageView.image = image
                            }
                        }
                        return
                    }
                    
                    DispatchQueue.main.async { [weak strongSelf] in
                        
                        if let selfInstance = strongSelf {
                            
                            //Make request to Fetch Image and update the cell
                            selfInstance.operation = BlockOperation(block: {
                                apiRequest.getImage(imageAPIEndPoint: selfInstance.apiPoint, imageKey: imageKey) {[weak selfInstance] (image,imageAPIEndPoint)  in
                                    if let instance = selfInstance {
                                        if let oper = instance.operation, !oper.isCancelled, imageAPIEndPoint == instance.apiPoint {
                                            OperationQueue.main.addOperation({
                                                instance.cellImageView.image = image
                                            })
                                        }
                                    }
                                }
                            })
                            
                            //Add Operation to Operation Queue
                            if let oper = selfInstance.operation {
                                apiRequest.concurrentQueue.addOperation(oper)
                            }
                        }
                        
                    }
                }
        
            }
        }
    }
    
    override func prepareForReuse() {
        apiPoint = ""
        cellImageView.image = nil
        operation?.cancel()
    }
}
