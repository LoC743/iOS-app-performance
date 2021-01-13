//
//  SaveUserDataOperation.swift
//  SocialAppVK
//
//  Created by Alexey on 13.01.2021.
//

import Foundation
import RealmSwift

class SaveUserDataOperation: AsyncOperation {
    override func main() {
        guard let parseData = dependencies.first as? ParseUserDataOperation else { return }
        let friendData = parseData.outputData
        
        let realm = try! Realm()
        
        let result = realm.objects(User.self)
        try? realm.write {
            realm.delete(result)
        }
        
        try? realm.write {
            realm.add(friendData, update: .modified)
        }
    }
}
