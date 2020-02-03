//
//  SearchCollectionViewController.swift
//  Gallery
//
//  Created by Dima Surkov on 05.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class SearchCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.style = .whiteLarge
        activity.hidesWhenStopped = true
        return activity
    }()
    
    private var imageList: [ImageList]? {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.hidesSearchBarWhenScrolling = true
                self.navigationItem.title = "Gallery"
                self.collectionView.reloadData()
            }
        }
    }
    
    private var selectedItemsForSave: [String: UIImage]? {
        didSet {
            guard let selectedItemsForSave = selectedItemsForSave  else { return }
            footerBarView.imageForSaveDict = selectedItemsForSave
        }
    }
    
    private let previewController = PreviewCollectionViewController()
    private let footerBarView = FooterBarView()

    private var doubleTapGesture: UITapGestureRecognizer?
    private var selectedFrame: CGRect?
    private var selectedImage: UIImage?
    private var previewFrameForSelectedCell: CGRect?
    private var totalImage: Int = 0

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(footerBarView)
        view.addSubview(activityIndicator)
        setupSearchBar()
        setupCollectionView()
        setupDoubleTap()
        goToLibrary()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        saveButtonPressed()
        diselectItems()
        scrollToCorrectCell()
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 60)
        footerBarView.frame = CGRect(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60)
        activityIndicator.frame = CGRect(x: view.center.x - 50, y: view.center.y - 50, width: 100, height: 100)
    }
    
    // MARK: - Init
    
    init() {
        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapTriggered))
        doubleTapGesture?.numberOfTapsRequired = 2
        guard let doubleTap = doubleTapGesture  else { return }
        view.addGestureRecognizer(doubleTap)
        doubleTapGesture?.delaysTouchesBegan = true
    }
    
    private func saveButtonPressed() {
        footerBarView.onSaveButtonPressed = { [weak self] in
            self?.diselectItems()
        }
    }
    
    private func diselectItems() {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        footerBarView.selected = true
        selectedItems.forEach { (index) in
            collectionView.deselectItem(at: index, animated: false)
        }
    }
    
    private func goToLibrary() {
        footerBarView.onLoadFromDirectoryDone = { [weak self] (image) in
            let libraryCotroller = LibraryCollectionViewController()
            libraryCotroller.imageListFromDirectory = image
            self?.diselectItems()
            self?.navigationController?.pushViewController(libraryCotroller, animated: true)
        }
    }
    
    private func getDataForAnimation(with indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else { return }
        guard let url = imageList?[indexPath.item].urls.thumb as NSString? else {return}
        guard let imageFromCache = imageCache.object(forKey: url) else { return }
        
        let cellFrame = collectionView.convert(selectedCell.frame, to: collectionView.superview)
        selectedFrame = cellFrame
        selectedImage = imageFromCache
        
        let deviceFactor = imageFromCache.size.width / previewController.view.bounds.width
        let y = (previewController.view.bounds.height - (imageFromCache.size.height / deviceFactor) + 64) / 2
        let previewFrame = CGRect(x: 0,
                                  y: y,
                                  width: imageFromCache.size.width / deviceFactor,
                                  height: imageFromCache.size.height / deviceFactor)
        previewFrameForSelectedCell = previewFrame
    }
    
    private func scrollToCorrectCell() {
        previewController.onScrollToNewItem = { [weak self] (indexPath) in
            self?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            self?.getDataForAnimation(with: indexPath)
        }
    }
    
    // MARK: - Actions
    
    @objc private func doubleTapTriggered() {
        guard let pointInCell = doubleTapGesture?.location(in: collectionView) else { return }
        footerBarView.onLibraryButtonPressed = false
        
        if let selectedIndexPath = collectionView.indexPathForItem(at: pointInCell) {
            getDataForAnimation(with: selectedIndexPath)
            previewController.imageList = imageList
            previewController.selectedItem = selectedIndexPath
            diselectItems()
            
            navigationController?.delegate = self
            navigationController?.pushViewController(previewController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        guard let stringImageURL = imageList?[indexPath.item].urls.thumb else { return UICollectionViewCell() }
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
        let width = (collectionView.bounds.width - (4 * 5)) / 4
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
        
        if imageList?.count == nil || totalImage == imageList?.count {
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
        var itemsForSave: [String: UIImage] = [:]
        footerBarView.selected = false
        
        selectedItems.forEach { (index) in
            guard let imageKey = imageList?[index.item].id else { return }
            guard let url = imageList?[index.item].urls.thumb as NSString? else { return }
            guard let cacheImageValue = imageCache.object(forKey: url) else { return }
            itemsForSave[imageKey] = cacheImageValue
        }
        selectedItemsForSave = itemsForSave
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        guard let imageKey = imageList?[indexPath.item].id else { return }
        
        if selectedItems.isEmpty {
            footerBarView.selected = true
        }
        selectedItemsForSave?.removeValue(forKey: imageKey)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        if totalImage != imageList?.count {
            Network.shared.fetchNextPageImagesURL { [weak self] model in
                guard let model = model else { return }
                
                DispatchQueue.main.async {
                    self?.imageList? += model.results
                }
            }
        }
    }
}

    // MARK: - UISearchBarDelegate

extension SearchCollectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        activityIndicator.startAnimating()
        
        Network.shared.fetchImagesURL(with: searchText) { [weak self] model in
            guard let model = model else { return }
            
            DispatchQueue.main.async {
                let imageModel = ImageModel(model: model)
                self?.imageList = imageModel.imageList
                self?.totalImage = imageModel.totalItem
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}

    // MARK: - UINavigationControllerDelegate

extension SearchCollectionViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if self.footerBarView.onLibraryButtonPressed == true { return nil }
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
