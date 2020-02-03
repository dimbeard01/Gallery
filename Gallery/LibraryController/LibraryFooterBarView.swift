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
    
    var onSaveButtonPressed: (() -> Void)?
    var imageForRemoveDict: [String: UIImage] = [:]
    var onRemoveButtonPressed: (() -> Void)?

    private lazy var saveOnDeviceGalleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .black
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "download"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor =  #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .black
        button.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "garbage"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
    
    @objc private func saveButtonPressed() {
        onSaveButtonPressed?()
    }
    
    @objc private func removeButtonPressed() {
        imageForRemoveDict.forEach { (key, _) in
            DeviceData.shared.removeImageFromDirectory(with: key)
        }
        selected = true
        onRemoveButtonPressed?()
    }
}
