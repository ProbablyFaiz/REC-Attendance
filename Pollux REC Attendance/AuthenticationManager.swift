//
//  AuthenticationManager.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 10/30/19.
//  Copyright © 2019 Faiz Surani. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AuthenticationManager {
    static func validateLoginAndGetInfo(accessToken: String, completion: @escaping (User?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let url = baseURL + "auth"
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(self.parseJson(json: json, headers: response.response?.allHeaderFields), nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    static func parseJson(json: JSON, headers: [AnyHashable: Any]?) -> User {
        let user = User()
        if json["existsOnServer"].bool == false {
            user.existsOnServer = false
            return user
        }
        user.existsOnServer = true
        if let bearerToken = headers!["Bearer-Token"] as? String {
            user.bearerToken = bearerToken
        }
        user.emailAddress = json["emailAddress"].string ?? ""
        user.firstName = json["firstName"].string ?? ""
        user.lastName = json["lastName"].string ?? ""
        user.teacherId = json["teacherId"].int ?? 0
        return user
    }
}
