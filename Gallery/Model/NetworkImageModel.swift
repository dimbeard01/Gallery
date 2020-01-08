//
//  NetworkImageModel.swift
//  Gallery
//
//  Created by Dima Surkov on 02.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

struct NetworkImageModel: Decodable {
    let total: Int
    let results: [ImageList]
}

struct ImageList: Decodable {
    let id: String
    let urls: ImageURL
}

struct ImageURL: Decodable {
    let regular: String
    let thumb: String
}
