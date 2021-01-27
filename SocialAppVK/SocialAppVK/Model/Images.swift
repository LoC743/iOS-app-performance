//
//  ProfileImages.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 24.11.2020.
//

import UIKit
import RealmSwift

struct Likes {
    var userLikes: Bool
    var count: Int
}

class VKImage: Object {
    @objc dynamic var height: Int = 0
    @objc dynamic var width: Int = 0
    @objc dynamic var url: String = ""
    
    var aspectRatio: CGFloat { return CGFloat(height)/CGFloat(width) }
    
    convenience init(url: String, height: Int, width: Int) {
        self.init()
        
        self.url = url
        self.height = height
        self.width = width
    }
    
    override class func primaryKey() -> String? {
        return "url"
    }
}

class Image: Object {
    @objc dynamic var ownerID: Int = -1
    @objc dynamic var albumID: Int = -1
    @objc dynamic var id: Int = -1
    
    @objc dynamic var date: Int = -1
    @objc dynamic var text: String = ""
    var likes: Likes = .init(userLikes: false, count: -1)
    var reposts: Int = -1
    
    @objc dynamic var photo50: VKImage?
    @objc dynamic var photo100: VKImage?
    @objc dynamic var photo200: VKImage?
    
    convenience init(ownerID: Int, albumID: Int, id: Int, date: Int, text: String, likes: Likes, reposts: Int, photo50: VKImage, photo100: VKImage, photo200: VKImage) {
        self.init()
        
        self.ownerID = ownerID
        self.albumID = albumID
        self.id = id
        self.date = date
        self.text = text
        self.likes = likes
        self.reposts = reposts
        self.photo50 = photo50
        self.photo100 = photo100
        self.photo200 = photo200
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


class ImageList: Decodable {
    var amount: Int = 0
    var images: [Image] = []
    
    enum ResponseCodingKeys: String, CodingKey {
        case response
    }
    
    enum ItemsCodingKeys: String, CodingKey {
        case count
        case items
    }
    
    enum VKImageCodingKeys: String, CodingKey {
        case ownerID = "owner_id"
        case albumID = "album_id"
        case id
        case userID = "user_id"
        case postID = "post_id"
        case date
        case sizes
        case text
        case likes
        case reposts
    }
    
    enum ImageSizeCodingKey: String, CodingKey  {
        case height
        case width
        case url
        case type
    }
    
    enum LikesCodingKeys: String, CodingKey {
        case userLikes = "user_likes"
        case count
    }
    
    enum RepostsCodingKeys: String, CodingKey {
        case count
    }
    
    required init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let values = try response.nestedContainer(keyedBy: ItemsCodingKeys.self, forKey: .response)
        // Получение {..{ count: Int, items [..] }..}
        let count = try values.decode(Int.self, forKey: .count)
        self.amount = count
        
        var items = try values.nestedUnkeyedContainer(forKey: .items)
        
        let itemsCount: Int = items.count ?? 0
        for _ in 0..<itemsCount {
            let imageContainer = try items.nestedContainer(keyedBy: VKImageCodingKeys.self)
            
            let ownerID = try imageContainer.decode(Int.self, forKey: .ownerID)
            let albumID = try imageContainer.decode(Int.self, forKey: .albumID)
            let id = try imageContainer.decode(Int.self, forKey: .id)
            
            let date = try imageContainer.decode(Int.self, forKey: .date)
            let text = try imageContainer.decode(String.self, forKey: .text)
            
            let likesContainer = try imageContainer.nestedContainer(keyedBy: LikesCodingKeys.self, forKey: .likes)
            let repostsContainer = try imageContainer.nestedContainer(keyedBy: RepostsCodingKeys.self, forKey: .reposts)
            
            let userLikesInt = try likesContainer.decode(Int.self, forKey: .userLikes)
            let userLikesBool = userLikesInt == 0 ? false : true
            let likesCount = try likesContainer.decode(Int.self, forKey: .count)
            
            let likes = Likes(userLikes: userLikesBool, count: likesCount)
            
            let repostsCount = try repostsContainer.decode(Int.self, forKey: .count)
            
            var imageSizeContainer = try imageContainer.nestedUnkeyedContainer(forKey: .sizes)
            let sizesCount: Int = imageSizeContainer.count ?? 0
            
            var photo50: VKImage = VKImage()
            var photo100: VKImage = VKImage()
            var photo200: VKImage = VKImage()
            for _ in 0..<sizesCount {
                let sizeContainer = try imageSizeContainer.nestedContainer(keyedBy: ImageSizeCodingKey.self)
                let height = try sizeContainer.decode(Int.self, forKey: .height)
                let width = try sizeContainer.decode(Int.self, forKey: .width)
                let url = try sizeContainer.decode(String.self, forKey: .url)
                let typeString = try sizeContainer.decode(String.self, forKey: .type)
                
                switch typeString {
                case "s":
                    photo50 = VKImage(url: url, height: height, width: width)
                case "m":
                    photo100 = VKImage(url: url, height: height, width: width)
                case "x":
                    photo200 = VKImage(url: url, height: height, width: width)
                default:
                    break
                }
            }
            
            let userImage = Image(ownerID: ownerID, albumID: albumID, id: id, date: date, text: text, likes: likes, reposts: repostsCount, photo50: photo50, photo100: photo100, photo200: photo200)
            images.append(userImage)
        }
        
    }
    
    init(images: [Image]) {
        self.images = images
        self.amount = images.count
    }
}
