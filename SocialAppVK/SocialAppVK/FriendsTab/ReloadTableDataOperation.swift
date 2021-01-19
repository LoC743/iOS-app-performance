//
//  ReloadTableDataOperation.swift
//  SocialAppVK
//
//  Created by Alexey on 13.01.2021.
//

import Foundation
import RealmSwift

class ReloadTableDataOperation: Operation {
    var controller: FriendsTableViewController
    
    init(controller: FriendsTableViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseData = dependencies.first as? ParseUserDataOperation else { return }
        let realm = try! Realm()
        
        let result = realm.objects(User.self)
        try? realm.write {
            realm.delete(result)
        }
        
        try? realm.write {
            realm.add(parseData.outputData, update: .modified)
        }
    }
    
}
