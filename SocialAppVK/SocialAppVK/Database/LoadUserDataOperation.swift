//
//  LoadUserDataOperation.swift
//  SocialAppVK
//
//  Created by Alexey on 13.01.2021.
//

import Foundation
import RealmSwift

class LoadUserDataOperation: Operation {
    var controller: FriendsTableViewController
    
    init(controller: FriendsTableViewController) {
        self.controller = controller
    }
    
    override func main() {
        let realm = try! Realm()
        controller.friendsData = realm.objects(User.self).sorted(byKeyPath: "order")
        print(controller.friendsData)
        controller.resetTableData()
    }
}
