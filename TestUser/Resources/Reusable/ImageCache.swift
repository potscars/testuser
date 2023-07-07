//
//  ImageCache.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import UIKit

class ImageCache {

    private init() {}

    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    func insert(image: UIImage, urlString: NSString) {
        cache.setObject(image, forKey: urlString)
    }
    
    func fetch(with urlString: NSString) -> UIImage? {
        return cache.object(forKey: urlString)
    }
}

