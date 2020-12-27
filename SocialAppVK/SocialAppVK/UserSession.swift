//
//  UserSession.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 20.11.2020.
//



// MARK: - Singleton Session
class UserSession {
    static let instance = UserSession()
    
    private init() {  }
    
    var token: String? = nil  // Токен VK
    var userID: Int? = nil    // Идентификатор пользователя VK
}
