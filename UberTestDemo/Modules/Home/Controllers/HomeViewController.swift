//
//  HomeViewController
//  UberTestDemo
//
//  Created by Suryanarayan Sahu on 12/12/18.
//  Copyright © 2018 Suryanarayan Sahu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //UI References
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionViewLabel: UILabel!
    
    
    //Page Specific Items
    var cellHeight: CGFloat = 0.0
    var cellWidth: CGFloat = 0.0
    var numberOfColumns: CGFloat = 3.0
    var footerHeight: CGFloat = 40.0
    var photoObjects = [PhotoModel]()
    var photoResponse: PhotosResponseModel?
    var loaderView: UbLoader?
    var lastTextSearch: String = ""
    var homePageRequest = HomePageRequest.init()
    
    //MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setupLoader()
    }

    //MARK: Collection View Set up
    
    //Set up Views
    func setViews() {
        
        //Set Collection View Cell sizes
        let screenWidth = Util.sharedInstance.screenWidth
        cellWidth = screenWidth/numberOfColumns
        cellHeight = cellWidth
        
        //Register cell for reuse
        photosCollectionView.register(UINib(nibName: Constant.HomeCell.PhotoCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constant.HomeCell.PhotoCollectionViewCellIdentifier)
        photosCollectionView.register(UINib(nibName: Constant.HomeCell.PhotoCollectionSectionFooterIdentifier, bundle: nil), forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter , withReuseIdentifier: Constant.HomeCell.PhotoCollectionSectionFooterIdentifier)
        
        //Set Collection View Datasource and Delegate
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        //Open Keyboard
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        //Show Description View
        descriptionView.isHidden = false
        descriptionViewLabel.text = Constant.AppStringConstant.searchMessage.rawValue
        
        //Hide Overlay
        overlayView.isHidden = true
        
    }
    
    //Set up Loader
    func setupLoader() {
        loaderView = UbLoader.init()
        loaderView?.configureView(onView: photosCollectionView)
        loaderView?.stopAnimating()
        homePageRequest.concurrentQueue.maxConcurrentOperationCount = 5
    }

    //MARK: OverLay Handling
    
    //Hide Overlay on Tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if self.overlayView.frame.contains(location) {
            overlayView.isHidden = true
            self.searchBar.resignFirstResponder()
            self.searchBar.text = lastTextSearch
            if photoObjects.count == 0 {
                descriptionView.isHidden = false
            }
        }
    }
    
    //
}

//MARK: Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
    
    //Text View Editing Begun
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)  {
        overlayView.isHidden = false
        descriptionView.isHidden = true
    }
    
    //Search Button Tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            self.getSearchData(searchText: searchText)
            if lastTextSearch == searchText {
                overlayView.isHidden = true
                return
            }
        }
    }
    
    //Get Search Data
    func getSearchData(searchText: String) {
        //Hide Keyboard
        searchBar.resignFirstResponder()
        
        //Handle search
        if searchText.isEmpty {
            
            //Set search bar text to last text search and hide overlay as per existing response
            searchBar.text = lastTextSearch
            overlayView.isHidden = true
            
        } else {
            
            //Check for the fetch number to be fetched
            var pageNumber = "1"
            if let photoModel = photoResponse, let currentPageNumber = photoModel.pageNumber, let lastPageNumber = photoModel.totalPages {
                
                //Identify if you have reached the end of the flow
                if currentPageNumber >= lastPageNumber {
                    return
                }
                
                pageNumber = "\(Int(currentPageNumber) + 1)"
            }
            
            //Hide Overlay
            overlayView.isHidden = true
            lastTextSearch = searchBar.text ?? lastTextSearch
            
            //Delete existing items in case of new search
            if let respModel = photoResponse, respModel.searchText != lastTextSearch {
                self.photosCollectionView.performBatchUpdates({
                    var indexPaths = [IndexPath]()
                    for (index,_) in self.photoObjects.enumerated() {
                        indexPaths.append(IndexPath.init(item: index, section: 0))
                    }
                    self.photosCollectionView.deleteItems(at: indexPaths)
                    self.photoObjects.removeAll()
                })
            }
            
            //Make network calls to fetch data
            self.loaderView?.startAnimating()
            
            homePageRequest.getSearchQueryData(searchText: searchText, pageNumber: pageNumber, completionHandler:{ (response, error, statusCode) in
                
                //Stop animation and start Parsing
                self.loaderView?.stopAnimating()
                
                //If response is not recieved but error is present Show Failure
                if response == nil, error != nil  {
                    if self.photoObjects.count == 0 {
                        self.descriptionView.isHidden = false
                        self.descriptionViewLabel.text = Constant.AppStringConstant.apiErrorMessage.rawValue
                    }
                } else if let photoModel = response {
                    
                    //Update Response if last search is same as response
                    if self.lastTextSearch == photoModel.searchText {
                        
                        //Update using Batch Updates
                        if let responsePhotoObjects = photoModel.photoModels, responsePhotoObjects.count > 0 {
                            self.photosCollectionView.performBatchUpdates({
                                self.photoResponse = response
                                var indexPaths = [IndexPath]()
                                for (_,object) in responsePhotoObjects.enumerated() {
                                    self.photoObjects.append(object)
                                    indexPaths.append(IndexPath.init(item: self.photoObjects.count - 1, section: 0))
                                }
                                self.photosCollectionView.insertItems(at: indexPaths)
                            })
                        }
                        
                    }
                    
                    //Incase of Zero Objects
                    if self.photoObjects.count == 0 {
                        self.descriptionView.isHidden = false
                        self.descriptionViewLabel.text = Constant.AppStringConstant.noResultsMessage.rawValue
                    }
                }
                
            })
        }
    }
    
}

//MARK: Collection View Data Source
extension HomeViewController: UICollectionViewDataSource {
    
    //Set Collection View Inset
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //Set Minimum Spacing for sections
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
    
    //Set Minimum Item Spacing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
    
    //Set Cell for row
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.HomeCell.PhotoCollectionViewCellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        if photoObjects.count > indexPath.item {
            cell.homePage = self
            cell.configureCell(model: photoObjects[indexPath.item])
        }
        return cell
    }
    
    //Set number of Items in Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoObjects.count
    }
    
    //Number of Sections in Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
            if let photoModel = photoResponse, let currentPageNumber = photoModel.pageNumber, let lastPageNumber = photoModel.totalPages {
                
                //Identify if you have reached the end of the flow
                if currentPageNumber >= lastPageNumber {
                    return
                }
                
                self.getSearchData(searchText: lastTextSearch)
            }
        }
    }
    
    //Footer View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //Set footer and show loader or no more results as per items
        var reusableView: UICollectionReusableView?
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Constant.HomeCell.PhotoCollectionSectionFooterIdentifier, for: indexPath) as! PhotoCollectionSectionFooterCollectionReusableView
            
            //If All data Shown show no more results
            if let photoModel = photoResponse, let currentPageNumber = photoModel.pageNumber, let lastPageNumber = photoModel.totalPages, currentPageNumber >= lastPageNumber{
                footerView.stopAnimating()
            } else {
                footerView.startAnimating()
            }
            
            reusableView = footerView
            
        default:
            return reusableView ?? UICollectionReusableView.init()
        }
        return reusableView ?? UICollectionReusableView.init()
    }
}

//MARK: Collection View Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    //Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    //Footer Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: Util.sharedInstance.screenWidth, height: photoObjects.count == 0 ? 0 : footerHeight)
    }
}
