//
//  ImagePreviewCollectionViewCell.swift
//  Gallery
//
//  Created by Dima Surkov on 05.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class ImagePreviewCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "identifier"
    
    private let image: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(image)
        image.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
    }
    
    // MARK: - Public
    
    func configure(with url: String) {
        image.loadLargeImage(with: url)
    }
}
