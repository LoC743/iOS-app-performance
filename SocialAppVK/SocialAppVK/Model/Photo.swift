//
//  Photo.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 24.11.2020.
//

import UIKit
import RealmSwift

class Photo: Object {
    @objc dynamic var photo_50: String = ""
    @objc dynamic var photo_100: String = ""
    @objc dynamic var photo_200: String = ""
    
    convenience init(photo_50: String, photo_100: String, photo_200: String) {
        self.init()
        
        self.photo_50 = photo_50
        self.photo_100 = photo_100
        self.photo_200 = photo_200
    }
}
