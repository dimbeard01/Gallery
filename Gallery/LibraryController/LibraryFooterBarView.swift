//
//  LibraryFooterBarView.swift
//  Gallery
//
//  Created by Dima Surkov on 08.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class LibraryFooterBarView: UIView {
    
    // MARK: - Properties
    
    var selected: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    var onSaved: (() -> Void)?
    
    private lazy var saveOnDeviceGalleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(saveOnDevice), for: .touchUpInside)
        button.setImage(UIImage(named: "saveOnDevice"), for: .normal)
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor =  #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(removeFromDirectory), for: .touchUpInside)
        button.setImage(UIImage(named: "remove"), for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.9097049236, green: 0.909860909, blue: 0.9096950889, alpha: 1)
        addSubview(removeButton)
        addSubview(saveOnDeviceGalleryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeButton.isHidden = selected
        saveOnDeviceGalleryButton.isHidden = selected

        removeButton.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        saveOnDeviceGalleryButton.frame = CGRect(x: self.bounds.width - 55, y: 5, width: 50, height: 50)
    }
    
    // MARK: - Actions
    
    @objc func saveOnDevice() {
        print("Save on device")
        onSaved?()
    }
    
    @objc func removeFromDirectory() {
        print("Remove from device")
    }
}
