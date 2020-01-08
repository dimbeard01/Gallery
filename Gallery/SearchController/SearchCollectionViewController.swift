//
//  SearchCollectionViewController.swift
//  Gallery
//
//  Created by Dima Surkov on 05.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

 class SearchCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var imageURLList: [ImageList]? {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.hidesSearchBarWhenScrolling = true
                self.navigationItem.title = "Gallery"
                self.collectionView.reloadData()
            }
        }
    }
    
    private var selectedItemsForSave: [String : UIImage]? {
        didSet {
            guard let selectedItemsForSave = selectedItemsForSave  else { return }
            footerBarView.imageForSaveDict = selectedItemsForSave
        }
    }
    
    private var doubleTapGesture: UITapGestureRecognizer?
    private let footerBarView = FooterBarView()

    var totalImage: Int = 0
    var selectedFrame: CGRect?
    var selectedImage: UIImage?
    var previewFrameForSelectedCell: CGRect?

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        setupDoubleTap()
        goToLibrary()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        view.addSubview(footerBarView)
        diselectItems()
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 60)
        footerBarView.frame = CGRect(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60)
    }
    
    // MARK: - Support
    
    private func setupCollectionView() {
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.register(LoaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .lightGray
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupDoubleTap() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture?.numberOfTapsRequired = 2
        guard let doubleTap = doubleTapGesture  else { return }
        view.addGestureRecognizer(doubleTap)
        doubleTapGesture?.delaysTouchesBegan = true
    }
    
    private func diselectItems() {
        footerBarView.onSaved = { [weak self] in
            guard let selectedItems = self?.collectionView.indexPathsForSelectedItems else { return }
            self?.footerBarView.selected = true
            selectedItems.forEach { (index) in
                self?.collectionView.deselectItem(at: index, animated: false)
            }
        }
    }
    
    private func goToLibrary() {
        let libraryCotroller = LibraryCollectionViewController()
        
        footerBarView.onLoadDone = { [weak self] (image) in
            libraryCotroller.imageList = image
            self?.navigationController?.pushViewController(libraryCotroller, animated: true)
        }
    }
    
    // MARK: - Actions

    @objc func didDoubleTap() {
        guard let pointInCell = doubleTapGesture?.location(in: self.collectionView) else { return }
        footerBarView.onLibraryButtonTapped = false
        if let selectedIndexPath = collectionView.indexPathForItem(at: pointInCell) {
            guard let selectedCell = collectionView.cellForItem(at: selectedIndexPath) else { return }
            guard let url = imageURLList?[selectedIndexPath.item].urls.thumb as NSString? else {return}
            guard let imageFromCache = imageCache.object(forKey: url) else { return }
            
            selectedFrame = selectedCell.frame
            selectedImage = imageFromCache
            
            let previewController = PreviewCollectionViewController()
            let renderFactor = imageFromCache.size.width / previewController.view.bounds.width
            
            previewFrameForSelectedCell = CGRect(x: 0,
                                                 y: previewController.view.bounds.midY - (( imageFromCache.size.height / renderFactor ) / 2.5),
                                                 width: imageFromCache.size.width / renderFactor,
                                                 height: imageFromCache.size.height / renderFactor)
            previewController.imageURLList = imageURLList
            previewController.selectedItem = selectedIndexPath
            navigationController?.delegate = self
            navigationController?.pushViewController(previewController, animated: true)
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension SearchCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        guard let imageURLList = imageURLList else { return UICollectionViewCell() }
        
        let stringImageURL = imageURLList[indexPath.item].urls.thumb
        cell.configure(with: stringImageURL)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter,
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoaderCollectionReusableView.identifier, for: indexPath) as? LoaderCollectionReusableView {
            footer.loaderIndicator.startAnimating()
            return footer
        } else {
            return UICollectionReusableView()
        }
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (4 * 5))/4
        let height = width
        return CGSize(width: width, height: height)
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if imageURLList?.count == nil || totalImage == imageURLList?.count {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
    }
    
}

    // MARK: - UICollectionViewDelegate

extension SearchCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        var itemsForSave: [String : UIImage] = [:]
        footerBarView.selected = false
        
        selectedItems.forEach { (index) in
            guard let imageURLList = imageURLList else { return }
            let imageKey = imageURLList[index.item].id
            guard let url = imageURLList[index.item].urls.thumb as NSString? else { return }
            guard let cacheImageValue = imageCache.object(forKey: url) else { return }
            itemsForSave[imageKey] = cacheImageValue
        }
        selectedItemsForSave = itemsForSave
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        if selectedItems.isEmpty {
            footerBarView.selected = true
        }
    }
 
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        if totalImage != imageURLList?.count {
            Network.shared.fetchNextPageImagesURL { [weak self] model in
                guard let model = model else { return }
                
                DispatchQueue.main.async {
                    self?.imageURLList? += model.results
                }
            }
        }
    }
}

    // MARK: - UISearchBarDelegate

extension SearchCollectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        Network.shared.fetchImagesURL(with: searchText) { [weak self] model in
            guard let model = model else { return }
            
            DispatchQueue.main.async {
                self?.imageURLList = nil
                let imageModel = ImageModel(model: model)
                self?.imageURLList = imageModel.imageURLList
                self?.totalImage = imageModel.totalItem
            }
        }
    }
}

extension SearchCollectionViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if self.footerBarView.onLibraryButtonTapped == true { return nil }
        guard let selectedFrame = self.selectedFrame else { return nil }
        guard let selectedImage = self.selectedImage else { return nil }
        guard let previewFrameForSelectedCell = self.previewFrameForSelectedCell else { return nil }

        switch operation {
        case .push:
            return CustomAnimator(duration: 0.3, isPresenting: true, originFrame: selectedFrame, image: selectedImage, previewImage: previewFrameForSelectedCell)
        default:
            return CustomAnimator(duration: 0.3, isPresenting: false, originFrame: selectedFrame, image: selectedImage, previewImage: previewFrameForSelectedCell)
        }
    }
}
