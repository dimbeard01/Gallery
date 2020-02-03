//
//  FooterBarView.swift
//  Gallery
//
//  Created by Dima Surkov on 05.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class FooterBarView: UIView {
    
    // MARK: - Properties

    var selected: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    var onLibraryButtonPressed: Bool?
    var onSaveButtonPressed: (() -> Void)?
    var onLoadFromDirectoryDone: (([[String: UIImage]]) -> Void)?
    var imageForSaveDict: [String: UIImage] = [:]

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .black
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "save"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    private lazy var moveToLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .black
        button.addTarget(self, action: #selector(moveToLibraryButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "folder"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.9097049236, green: 0.909860909, blue: 0.9096950889, alpha: 1)
        addSubview(saveButton)
        addSubview(moveToLibraryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        saveButton.isHidden = selected
        saveButton.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        moveToLibraryButton.frame = CGRect(x: self.bounds.width - 55, y: 5, width: 50, height: 50)
    }
  
    // MARK: - Actions

    @objc private func saveButtonPressed() {
        imageForSaveDict.forEach { (key, value) in
            DeviceData.shared.saveImageDocumentDirectory(image: value, imageName: key)
        }
        onSaveButtonPressed?()
    }
    
    @objc private func moveToLibraryButtonPressed() {
        onLibraryButtonPressed = true
        guard let itemsFromDirectory: [[String: UIImage]] = DeviceData.shared.getDataDocumentDirectory() else { return }
        onLoadFromDirectoryDone?(itemsFromDirectory)
    }
}
