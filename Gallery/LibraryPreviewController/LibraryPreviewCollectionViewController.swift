//
//  LibraryPreviewCollectionViewController.swift
//  Gallery
//
//  Created by Dima Surkov on 08.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class LibraryPreviewCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    var imageList: [UIImage]? {
        didSet {
            DispatchQueue.main.async {
                self.scrollToSelectedItem()
                self.collectionView.reloadData()
            }
        }
    }
        
    var totalImage: Int = 0
    var selectedItem: IndexPath?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
        collectionView.backgroundColor = .lightGray
        collectionView.isPagingEnabled = true
        collectionView.register(LibraryPreviewCollectionViewCell.self, forCellWithReuseIdentifier: LibraryPreviewCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func scrollToSelectedItem() {
        guard let indexPath = selectedItem else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

    // MARK: - UICollectionViewDataSource

extension LibraryPreviewCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryPreviewCollectionViewCell.identifier, for: indexPath) as? LibraryPreviewCollectionViewCell else { return UICollectionViewCell() }
        
        guard let imageFromDirectory = imageList?[indexPath.item] else { return UICollectionViewCell() }
        
        cell.configure(with: imageFromDirectory)
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension LibraryPreviewCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
