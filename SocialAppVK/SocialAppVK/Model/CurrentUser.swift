//
//  CurrentUser.swift
//  SocialAppVK
//
//  Created by Alexey on 11.12.2020.
//

class CurrentUser: Decodable {
    var id: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var screenName: String = ""
    
    enum ResponseCodingKeys: String, CodingKey {
        case response
    }
    
    enum CurrentUserProfileCodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case screenName = "screen_name"
    }
    
    required init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let profile = try response.nestedContainer(keyedBy: CurrentUserProfileCodingKeys.self, forKey: .response)
        
        self.id = try profile.decode(Int.self, forKey: .id)
        self.firstName = try profile.decode(String.self, forKey: .firstName)
        self.lastName = try profile.decode(String.self, forKey: .lastName)
        self.screenName = try profile.decode(String.self, forKey: .screenName)
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "id" : id,
            "firstName": firstName,
            "lastName": lastName,
            "screenName": screenName
        ]
    }
}
