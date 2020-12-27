//
//  CustomAlomafireSession.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 20.11.2020.
//

import Alamofire

extension Session {
    static let custom: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        let sessionManager = Session(configuration: configuration)
        
        return sessionManager
    }()
}
