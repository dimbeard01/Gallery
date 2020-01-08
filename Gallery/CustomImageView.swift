//
//  CustomImageView.swift
//  Gallery
//
//  Created by Dima Surkov on 04.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

final class CustomImageView: UIImageView {
    
    private var imageUrlString: String?
    private var largeImageUrlString: String?

    func loadThumbImage(with url: String) {
        imageUrlString = url
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url as NSString) {
            self.image = imageFromCache
            return
        }
        
        Network.shared.fetchImage(with: url) { [weak self] model in
            guard let model = model else { return }
            
            DispatchQueue.main.async {
                let imageToCache = model
                imageCache.setObject(imageToCache, forKey: url as NSString)
                self?.image = imageToCache
            }
        }
    }
    
    func loadLargeImage(with url: String) {
        largeImageUrlString = url
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url as NSString) {
            self.image = imageFromCache
            return
        }
        
        Network.shared.fetchImage(with: url) { [weak self] model in
            guard let model = model else { return }
        
            DispatchQueue.main.async {
                let imageToCache = model
                imageCache.setObject(imageToCache, forKey: url as NSString)
                self?.image = imageToCache
            }
        }
    }
}
