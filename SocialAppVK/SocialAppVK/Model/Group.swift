//
//  Group.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 05.10.2020.
//

import UIKit
import RealmSwift

class Group: Object, CellModel {
    @objc dynamic var id: Int = -1
    @objc dynamic var isMember: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var photo: Photo? = nil
    
    @objc dynamic var orderNumber: Int = -1
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, isMember: Bool, name: String, photo: Photo, order: Int) {
        self.init()
        
        self.id = id
        self.isMember = isMember
        self.name = name
        self.photo = photo
        self.orderNumber = order
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "isMember": isMember,
            "photo": photo?.photo_200 ?? ""
        ]
    }
}

class GroupList: Decodable {
    var amount: Int = 0
    var groups: [Group] = []
    
    enum ResponseCodingKeys: String, CodingKey {
        case response
    }
    
    enum ItemsCodingKeys: String, CodingKey {
        case count
        case items
    }
    
    enum GroupKeys: String, CodingKey {
        case id
        case isMember = "is_member"
        case name
        case photo_50
        case photo_100
        case photo_200
    }
    
    required init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let values = try response.nestedContainer(keyedBy: ItemsCodingKeys.self, forKey: .response)
        // Получение {..{ count: Int, items [..] }..}
        let count = try values.decode(Int.self, forKey: .count)
        self.amount = count
        
        var items = try values.nestedUnkeyedContainer(forKey: .items)
        
        let itemsCount: Int = items.count ?? 0
        for i in 0..<itemsCount {
            let groupContainer = try items.nestedContainer(keyedBy: GroupKeys.self)
            let id = try groupContainer.decode(Int.self, forKey: .id)
            let name = try groupContainer.decode(String.self, forKey: .name)
            let isMemberInt = try groupContainer.decode(Int.self, forKey: .isMember)
            let isMemberBool = isMemberInt == 0 ? false : true
            let photo50 = try groupContainer.decode(String.self, forKey: .photo_50)
            let photo100 = try groupContainer.decode(String.self, forKey: .photo_100)
            let photo200 = try groupContainer.decode(String.self, forKey: .photo_200)
            
            let photo = Photo(photo_50: photo50, photo_100: photo100, photo_200: photo200)
            let group = Group(id: id, isMember: isMemberBool, name: name, photo: photo, order: i)
            
            self.groups.append(group)
        }
    }
}
