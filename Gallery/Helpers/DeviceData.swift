//
//  DeviceData.swift
//  Gallery
//
//  Created by Dima Surkov on 08.01.2020.
//  Copyright © 2020 Dima Surkov. All rights reserved.
//

import UIKit

final class DeviceData {
    
    static let shared = DeviceData()
  
    func saveImageDocumentDirectory(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("galleryImages")
        
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
               print("error of creating Dirctory")
            }
        }
        
        let url = NSURL(string: path)
        let imagePath = url!.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
    
    func getDataDocumentDirectory() -> [[String: UIImage]]? {
        let fileManager = FileManager.default
        var contentList: [String] = []
        var dataList = [[String: UIImage]]()

        guard let directoryPath = getDirectoryPath() as NSURL? else { return nil }
        guard let path = directoryPath.absoluteString else { return nil }
        
        do {
            let content = try fileManager.contentsOfDirectory(atPath: path)
            contentList = content
        } catch {
            print("error of getting content")
        }
        
        contentList.forEach { (key) in
            guard let imagePath = directoryPath.appendingPathComponent(key) else { return }
            let urlString: String = imagePath.absoluteString
            
            if fileManager.fileExists(atPath: urlString) {
                guard let image = UIImage(contentsOfFile: urlString) else { return }
                dataList.append([key: image])
            } else {
                return
            }
        }
        return dataList
    }
    
    func removeImageFromDirectory(with imageName: String) {
        let fileManager = FileManager.default
        let yourProjectImagesPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("galleryImages/\(imageName)")

        if fileManager.fileExists(atPath: yourProjectImagesPath) {
            do {
                try fileManager.removeItem(atPath: yourProjectImagesPath)
            } catch {
              print("error of removing")
            }
        }
    }
    
    private func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("galleryImages")
        guard let url = NSURL(string: path) else { return NSURL() }
        return url
    }
}
