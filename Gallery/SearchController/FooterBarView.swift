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
    
    var onLibraryButtonTapped: Bool?
    var onSaved: (() -> Void)?
    var onLoadDone: (([UIImage]) -> Void)?
    var imageForSaveDict: [String : UIImage] = [:]

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
    
        button.tintColor = .black
        button.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        button.setImage(UIImage(named: "save"), for: .normal)
        return button
    }()
    
    private lazy var moveToLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.7879012227, green: 0.7959392071, blue: 0.8083154559, alpha: 1)
        button.tintColor = .black
        button.addTarget(self, action: #selector(goToLibrary), for: .touchUpInside)
        button.setImage(UIImage(named: "folder"), for: .normal)
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

    @objc func saveImage() {
        imageForSaveDict.forEach { (key, value) in
            value.saveImageDocumentDirectory(image: value, imageName: key)
        }
        onSaved?()
    }
    
    @objc func goToLibrary() {
        onLibraryButtonTapped = true
        guard let images: [UIImage] = UIImage().getImageFromDocumentDirectory() else { return }
        onLoadDone?(images)
    }
}
