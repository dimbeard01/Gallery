//
//  LoaderCollectionReusableView.swift
//  Gallery
//
//  Created by Dima Surkov on 04.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class LoaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let identifier: String = "identifier"
    
    let loaderIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        return loader
    }()
 
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(loaderIndicator)
        loaderIndicator.frame = CGRect(x: center.x - 25, y: 0, width: 50, height: 50)
    }
}
