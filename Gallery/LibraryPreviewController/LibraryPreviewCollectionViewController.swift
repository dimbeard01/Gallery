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
    
    var imageList: [[String: UIImage]]? {
        didSet {
            DispatchQueue.main.async {
                self.scrollToSelectedItem()
                self.collectionView.reloadData()
            }
        }
    }
    var selectedItem: IndexPath?
    var onScrollToNewItem: ((IndexPath) -> Void)?

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupCustomBackBarButton()
        scrollToSelectedItem()
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
    
    private func setupCustomBackBarButton() {
        let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backBarButtonPressed))
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    private func scrollToSelectedItem() {
        guard let indexPath = selectedItem else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    // MARK: - Actions
    
    @objc func backBarButtonPressed() {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        onScrollToNewItem?(indexPath)
        navigationController?.popViewController(animated: true)
    }
}

    // MARK: - UICollectionViewDataSource

extension LibraryPreviewCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryPreviewCollectionViewCell.identifier, for: indexPath) as? LibraryPreviewCollectionViewCell else { return UICollectionViewCell() }
        
        guard let imageList = imageList?[indexPath.item] else { return UICollectionViewCell() }
        cell.configure(with: imageList)
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension LibraryPreviewCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let height = collectionView.bounds.height - 64
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
