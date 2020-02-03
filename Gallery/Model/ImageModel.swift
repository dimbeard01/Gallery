//
//  ImageModel.swift
//  Gallery
//
//  Created by Dima Surkov on 02.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class ImageModel {
    
    let imageList: [ImageList]
    let totalItem: Int

    init(model: NetworkImageModel) {
        self.imageList = model.results
        self.totalItem = model.total
    }
}
