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
    
    var imageList: [UIImage]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var imageURLList: [ImageList]? {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.title = "Gallery"
                self.collectionView.reloadData()
            }
        }
    }
    
    private var doubleTapGesture: UITapGestureRecognizer?
    private let libraryFooterBarView = LibraryFooterBarView()
    let libraryPreviewController =  LibraryPreviewCollectionViewController()

    var selectedFrame: CGRect?
    var selectedImage: UIImage?
    var previewFrameForSelectedCell: CGRect?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDoubleTap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(libraryFooterBarView)
        diselectItems()
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
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture?.numberOfTapsRequired = 2
        guard let doubleTap = doubleTapGesture else { return }
        view.addGestureRecognizer(doubleTap)
        doubleTapGesture?.delaysTouchesBegan = true
    }
    
    private func diselectItems() {
        libraryFooterBarView.onSaved = { [weak self] in
            guard let selectedItems = self?.collectionView.indexPathsForSelectedItems else { return }
            self?.libraryFooterBarView.selected = true
            selectedItems.forEach { (index) in
                self?.collectionView.deselectItem(at: index, animated: false)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func didDoubleTap() {
        guard let pointInCell = doubleTapGesture?.location(in: self.collectionView) else { return }
        if let selectedIndexPath = collectionView.indexPathForItem(at: pointInCell) {
            guard let selectedCell = collectionView.cellForItem(at: selectedIndexPath) else { return }
            guard let imageFromDirectory = imageList?[selectedIndexPath.item] else { return }

            selectedFrame = selectedCell.frame
            selectedImage = imageFromDirectory
            
            let libraryPreviewController =  LibraryPreviewCollectionViewController()
            let renderFactor = imageFromDirectory.size.width / libraryPreviewController.view.bounds.width
            
            previewFrameForSelectedCell = CGRect(x: 0,
                                                 y: libraryPreviewController.view.bounds.midY - (( imageFromDirectory.size.height / renderFactor ) / 3),
                                                 width: imageFromDirectory.size.width / renderFactor,
                                                 height: imageFromDirectory.size.height / renderFactor)
            
            libraryPreviewController.imageList = imageList
            libraryPreviewController.selectedItem = selectedIndexPath
            navigationController?.pushViewController(libraryPreviewController, animated: true)
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension LibraryCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCell.identifier, for: indexPath) as? LibraryCollectionViewCell else { return UICollectionViewCell() }
        
        guard let imageList = imageList?[indexPath.item] else { return UICollectionViewCell() }
        cell.configure(with: imageList)
        return cell
    }

}

    // MARK: - UICollectionViewDelegateFlowLayout

extension LibraryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
    }
    
}

    // MARK: - UICollectionViewDelegate

extension LibraryCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        libraryFooterBarView.selected = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        if selectedItems.isEmpty {
            libraryFooterBarView.selected = true
        }
    }
}
