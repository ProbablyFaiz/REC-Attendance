//
//  AlamofireManager.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 10/30/19.
//  Copyright © 2019 Ibrahim Surani. All rights reserved.
//

import Foundation
import Alamofire

class CustomManager: SessionManager {
    static var manager = CustomManager.generateManager()
    class func generateManager()-> CustomManager {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Authorization"] = currentUser.bearerToken
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        let manager = CustomManager(configuration: configuration)
        return manager
    }
}
