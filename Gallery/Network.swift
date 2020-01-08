//
//  Network.swift
//  Gallery
//
//  Created by Dima Surkov on 01.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class Network {
    
    private let baseURL: String = "https://api.unsplash.com/search/photos"
    private var pageCout = 2
    private var searchQuery: String = ""

    static let shared = Network()
    
    func fetchImagesURL(with query: String, completion: @escaping (NetworkImageModel?) -> Void) {

        imageCache.removeAllObjects()
        searchQuery = query
        
        let accessKey = "bf8a5599911a4a86f99f8d8c80b21cdd132763ebacc300014ea2345fb0a25b0a"
        let queryString = "\(baseURL)?per_page=30&page=1&query=\(searchQuery)&client_id=\(accessKey)"
        
        guard let url = URL(string: queryString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            #if DEBUG
            print(response.debugDescription)
            #endif
            
            guard let data = data else { return completion(nil) }
            
            if let networkModel = try? JSONDecoder().decode(NetworkImageModel.self, from: data) {
                completion(networkModel)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func fetchNextPageImagesURL(completion: @escaping (NetworkImageModel?) -> Void) {
        
        let accessKey = "bf8a5599911a4a86f99f8d8c80b21cdd132763ebacc300014ea2345fb0a25b0a"
        let queryString = "\(baseURL)?per_page=30&page=\(pageCout)&query=\(searchQuery)&client_id=\(accessKey)"
        
        guard let url = URL(string: queryString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            #if DEBUG
            print(response.debugDescription)
            #endif
            
            guard let data = data else { return completion(nil) }
            
            if let networkModel = try? JSONDecoder().decode(NetworkImageModel.self, from: data) {
                self.pageCout += 1
                completion(networkModel)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    
    func fetchImage(with stringUrl: String, completion: @escaping (UIImage?) -> Void) {
        
        guard let url = URL(string: stringUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            #if DEBUG
            print(response.debugDescription)
            #endif
            
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
