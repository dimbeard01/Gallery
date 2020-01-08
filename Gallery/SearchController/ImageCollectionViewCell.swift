//
//  ImageCollectionViewCell.swift
//  Gallery
//
//  Created by Dima Surkov on 02.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "identifier"
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                alpha = 0.5
            } else {
                alpha = 1
            }
        }
    }
    
    private let image: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
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
        image.loadThumbImage(with: url)
    }
}




