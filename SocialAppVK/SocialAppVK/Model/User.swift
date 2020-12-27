//
//  User.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 05.10.2020.
//

import UIKit
import RealmSwift

protocol CellModel {
    var name: String { get }
    var photo: Photo? { get }
}

enum Sex: Int {
    case female = 1
    case male = 2
    case empty = -1
}

//struct City {
//    var id: Int
//    var title: String
//}

class User: Object, CellModel {
    @objc dynamic var id: Int = -1
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var gender: Int {
        get {
            return sex.rawValue
        }
    }
//    var city: City?
    @objc dynamic var hasPhoto: Bool = false
    @objc dynamic var photo: Photo? = nil
    
    var sex: Sex = .empty
    
    var name: String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, firstName: String, lastName: String, sex: Sex, hasPhoto: Bool, photo: Photo) {
        self.init()
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.sex = sex
        self.hasPhoto = hasPhoto
        self.photo = photo
    }
}

class FriendList: Decodable {
    var amount: Int = 0
    var friends: [User] = []
    
    enum ResponseCodingKeys: String, CodingKey {
        case response
    }
    
    enum ItemsCodingKeys: String, CodingKey {
        case count
        case items
    }
    
    enum FriendCodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case sex
//        case city
        case hasPhoto = "has_photo"
        case photo50 = "photo_50"
        case photo100 = "photo_100"
        case photo200 = "photo_200"
    }
    
    enum CityCodingKeys: String, CodingKey {
        case id
        case title
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
            let friendContainer = try items.nestedContainer(keyedBy: FriendCodingKeys.self)
            let id = try friendContainer.decode(Int.self, forKey: .id)
            let firstName = try friendContainer.decode(String.self, forKey: .firstName)
            let lastName = try friendContainer.decode(String.self, forKey: .lastName)
            let sexInt = try friendContainer.decode(Int.self, forKey: .sex)
            let hasPhotoInt = try friendContainer.decode(Int.self, forKey: .hasPhoto)
            let hasPhotoBool = hasPhotoInt == 0 ? false : true
            let photo50 = try friendContainer.decode(String.self, forKey: .photo50)
            let photo100 = try friendContainer.decode(String.self, forKey: .photo100)
            let photo200 = try friendContainer.decode(String.self, forKey: .photo200)
            
//            let cityContainer = try friendContainer.nestedContainer(keyedBy: CityCodingKeys.self, forKey: .city)
//            let cityID = try cityContainer.decode(Int.self, forKey: .id)
//            let cityTitle = try cityContainer.decode(String.self, forKey: .title)

            let photo = Photo(photo_50: photo50, photo_100: photo100, photo_200: photo200)
//            let city = City(id: cityID, title: cityTitle)
            let sex = Sex(rawValue: sexInt) ?? .empty
//            let friend = User(id: id, firstName: firstName, lastName: lastName, sex: sex, city: city, hasPhoto: hasPhotoBool, photo: photo)
            let friend = User(id: id, firstName: firstName, lastName: lastName, sex: sex, hasPhoto: hasPhotoBool, photo: photo)
            
            self.friends.append(friend)
        }
    }
}
