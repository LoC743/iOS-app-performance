//
//  ParseUserDataOperation.swift
//  SocialAppVK
//
//  Created by Alexey on 13.01.2021.
//

import Foundation

class ParseUserDataOperation: Operation {
    
    var outputData: [User] = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
              let data = getDataOperation.data,
              let friendList = try? JSONDecoder().decode(FriendList.self, from: data)
        else {
            print("Failed to pase friend JSON!")
            return
        }
        
        outputData = friendList.friends
    }
    
}
