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

class City: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var title: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, title: String) {
        self.init()
        
        self.id = id
        self.title = title
    }
}

class User: Object, CellModel {
    // Basic fields
    @objc dynamic var id: Int = -1
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    
    // Optional fields
    @objc dynamic var birthDay: String? = nil
    @objc dynamic var gender: Int = 0
    @objc dynamic var city: City?
    @objc dynamic var hasPhoto: Bool = false
    @objc dynamic var photo: Photo? = nil
    @objc dynamic var isOnline: Bool = false
    
    // Extra
    var name: String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, firstName: String, lastName: String, gender: Int, hasPhoto: Bool, photo: Photo?, city: City?, isOnline: Bool, birthDay: String?) {
        self.init()
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.hasPhoto = hasPhoto
        self.photo = photo
        self.city = city
        self.isOnline = isOnline
        self.birthDay = birthDay
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
        case city
        case online
        case bdate
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
            // Basic fields
            let id = try friendContainer.decode(Int.self, forKey: .id)
            let firstName = try friendContainer.decode(String.self, forKey: .firstName)
            let lastName = try friendContainer.decode(String.self, forKey: .lastName)
            
            // Optional fields
            let sexInt = try? friendContainer.decode(Int.self, forKey: .sex)
            let sex: Int = sexInt ?? 0
            
            let birthDayString = try? friendContainer.decode(String.self, forKey: .bdate)
            
            let hasPhotoInt = try? friendContainer.decode(Int.self, forKey: .hasPhoto)
            let hasPhotoBool = hasPhotoInt == 0 ? false : true
            
            let isOnlineInt = try? friendContainer.decode(Int.self, forKey: .online)
            let isOnlineBool = isOnlineInt == 0 ? false : true
            
            var city: City?
            let cityContainer = try? friendContainer.nestedContainer(keyedBy: CityCodingKeys.self, forKey: .city)
            if let cityContainer = cityContainer {
                let cityID = try cityContainer.decode(Int.self, forKey: .id)
                let cityTitle = try cityContainer.decode(String.self, forKey: .title)
                city = City(id: cityID, title: cityTitle)
            }
            
            let photo50 = try? friendContainer.decode(String.self, forKey: .photo50)
            let photo100 = try? friendContainer.decode(String.self, forKey: .photo100)
            let photo200 = try? friendContainer.decode(String.self, forKey: .photo200)
            let photo = Photo(photo_50: photo50 ?? "", photo_100: photo100 ?? "", photo_200: photo200 ?? "")
            
            let friend = User(id: id, firstName: firstName, lastName: lastName, gender: sex, hasPhoto: hasPhotoBool, photo: photo, city: city, isOnline: isOnlineBool, birthDay: birthDayString)
            
            self.friends.append(friend)
        }
    }
}
