//
//  LibraryCollectionViewController.swift
//  Gallery
//
//  Created by Dima Surkov on 08.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class LibraryCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties

    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private var selectedItemsForRemove: [String: UIImage]? {
        didSet {
            guard let selectedItemsForRemove = selectedItemsForRemove  else { return }
            libraryFooterBarView.imageForRemoveDict = selectedItemsForRemove
        }
    }
    
    var imageListFromDirectory: [[String: UIImage]]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private let libraryFooterBarView = LibraryFooterBarView()
    private let libraryPreviewController = LibraryPreviewCollectionViewController()
    
    private var doubleTapGesture: UITapGestureRecognizer?
    private var selectedFrame: CGRect?
    private var selectedImage: UIImage?
    private var previewFrameForSelectedCell: CGRect?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDoubleTap()
        view.addSubview(libraryFooterBarView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        diselectItems()
        saveOnDevice()
        removeFromDirectoryDone()
        scrollToCorrectCell()
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 60)
        libraryFooterBarView.frame = CGRect(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60)
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
        collectionView.register(LibraryCollectionViewCell.self, forCellWithReuseIdentifier: LibraryCollectionViewCell.identifier)
        collectionView.backgroundColor = .lightGray
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupDoubleTap() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapTriggered))
        doubleTapGesture?.numberOfTapsRequired = 2
        guard let doubleTap = doubleTapGesture else { return }
        view.addGestureRecognizer(doubleTap)
        doubleTapGesture?.delaysTouchesBegan = true
    }
    
    private func diselectItems() {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        libraryFooterBarView.selected = true
        
        selectedItems.forEach { (index) in
            collectionView.deselectItem(at: index, animated: false)
        }
    }
    
    private func saveOnDevice() {
        libraryFooterBarView.onSaveButtonPressed = { [weak self] in
            guard let selectedItems = self?.collectionView.indexPathsForSelectedItems else { return }
            let alertController = UIAlertController(title: "To save images on photo library?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                let saveDoneAlertControler = UIAlertController(title: "Save is done", message: "Image saved successfully", preferredStyle: .alert)
                let saveDoneOkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                selectedItems.forEach { (index) in
                    guard let imageList = self?.imageListFromDirectory?[index.item].values.first else { return }
                    UIImageWriteToSavedPhotosAlbum(imageList, nil, nil, nil)
                }
                
                saveDoneAlertControler.addAction(saveDoneOkAction)
                self?.present(saveDoneAlertControler, animated: true, completion: nil)
            })

            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self?.diselectItems()
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func removeFromDirectoryDone() {
        libraryFooterBarView.onRemoveButtonPressed = { [weak self] in
            self?.imageListFromDirectory = DeviceData.shared.getDataDocumentDirectory()
        }
    }
    
    private func getDataForAnimation(with indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else { return }
        guard let imageFromDirectory = imageListFromDirectory?[indexPath.item].first?.value else { return }
        
        let cellFrame = collectionView.convert(selectedCell.frame, to: collectionView.superview)
        selectedFrame = cellFrame
        selectedImage = imageFromDirectory
        
        let deviceFactor = imageFromDirectory.size.width / libraryPreviewController.view.bounds.width
        let y = (libraryPreviewController.view.bounds.height - (imageFromDirectory.size.height / deviceFactor) + 64) / 2
        let previewFrame = CGRect(x: 0,
                                  y: y,
                                  width: imageFromDirectory.size.width / deviceFactor,
                                  height: imageFromDirectory.size.height / deviceFactor)
        previewFrameForSelectedCell = previewFrame
    }
    
    private func scrollToCorrectCell() {
        libraryPreviewController.onScrollToNewItem = { [weak self] (indexPath) in
            self?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            self?.getDataForAnimation(with: indexPath)
        }
    }
    
    // MARK: - Actions
  
    @objc private func doubleTapTriggered() {
        guard let pointInCell = doubleTapGesture?.location(in: self.collectionView) else { return }
        if let selectedIndexPath = collectionView.indexPathForItem(at: pointInCell) {
            getDataForAnimation(with: selectedIndexPath)
            libraryPreviewController.imageList = imageListFromDirectory
            libraryPreviewController.selectedItem = selectedIndexPath
            diselectItems()

            navigationController?.delegate = self
            navigationController?.pushViewController(libraryPreviewController, animated: true)
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension LibraryCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageListFromDirectory?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCell.identifier, for: indexPath) as? LibraryCollectionViewCell else { return UICollectionViewCell() }

        guard let imageList = imageListFromDirectory?[indexPath.item] else { return UICollectionViewCell() }
        cell.configure(with: imageList)
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension LibraryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
    }
}

    // MARK: - UICollectionViewDelegate

extension LibraryCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        var itemsForRemove: [String: UIImage] = [:]
        libraryFooterBarView.selected = false
    
        selectedItems.forEach { (index) in
            guard let imageKey = imageListFromDirectory?[index.item].keys.first else { return }
            let imageValue = imageListFromDirectory?[index.item].values.first
            itemsForRemove[imageKey] = imageValue
        }
        selectedItemsForRemove = itemsForRemove
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        guard let imageKey = imageListFromDirectory?[indexPath.item].keys.first else { return }
        
        if selectedItems.isEmpty {
            libraryFooterBarView.selected = true
        }
        selectedItemsForRemove?.removeValue(forKey: imageKey)
    }
}

    // MARK: - UINavigationControllerDelegate

extension LibraryCollectionViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (toVC is SearchCollectionViewController || toVC is LibraryCollectionViewController) &&
            (fromVC is LibraryCollectionViewController || fromVC is  SearchCollectionViewController) {
            return nil
        }
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
