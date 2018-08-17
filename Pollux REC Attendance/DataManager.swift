//
//  DataManager.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 12/16/17.
//  Copyright © 2017 Ibrahim Surani. All rights reserved.
//
//  Disable arbitrary loads before submission

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NotificationBannerSwift

let baseURL = "https://recwebapi20180817111320.azurewebsites.net/api/rec/"

class DataGetter {
    
    static func getSessionData(sessionId: Int, completion: @escaping (SessionAttendance?, Error?) -> Void) {
        
        let session = SessionAttendance()
        let requestUrl = baseURL + "session/" + String(sessionId)
        var sessionJSON = JSON()
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                sessionJSON = JSON(value)
                print("JSON: \(sessionJSON)")
                self.populateSession(session, sessionJSON, useStudents: true)
                completion(session,nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    static func getSessionList(teacherId: Int, monthAndYear: String, completion: @escaping ([SessionAttendance]?, Error?) -> Void) {
        var sessionList = [SessionAttendance]()
        let requestUrl = baseURL + "sessionlist/" + String(teacherId) + "&month=" + monthAndYear
        var sessionListJSON = JSON()
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                sessionListJSON = JSON(value)
                print("JSON: \(sessionListJSON)")
                for (_, session) in sessionListJSON {
                    let currentSession = SessionAttendance()
                    self.populateSession(currentSession, session, useStudents: false)
                    sessionList.append(currentSession)
                }
                completion(sessionList,nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func populateSession(_ session: SessionAttendance, _ sessionJSON: JSON, useStudents: Bool) {
        if useStudents {
            session.students = self.populateStudentsArr(sessionJSON["students"])    }
        session.classInfo = self.populateClassInfo(sessionJSON["classInfo"])
        session.sessionId = sessionJSON["sessionId"].int!
        session.date = jsonToDate(sessionJSON["date"])
    }
    
    fileprivate static func populateStudentsArr(_ studentJSON: JSON) -> [StudentAttendance] {
        var studentArr = [StudentAttendance]()
        for (_, student) in studentJSON {
            let newStudent = StudentAttendance()
            newStudent.attendanceStatusId = student["attendanceStatusId"].int!
            newStudent.reasonId = student["reasonId"].int!
            newStudent.name = student["studentName"].string!
            newStudent.studentId = student["studentId"].int!
            studentArr.append(newStudent)
        }
        return studentArr
    }
    
    fileprivate static func populateClassInfo(_ classInfoJSON: JSON) -> ClassInfo {
        let classInfo = ClassInfo()
        classInfo.classId = classInfoJSON["classId"].int!
        classInfo.className = classInfoJSON["className"].string!
        classInfo.classDescription = classInfoJSON["classDescription"].string ?? ""
        classInfo.primaryTeacherName = classInfoJSON["primaryTeacherName"].string ?? ""
        classInfo.recName = classInfoJSON["recName"].string ?? ""
        return classInfo
    }
    
    static func jsonToDate(_ dateJSON: JSON) -> Date { //TODO: Fix this
        var date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date = dateFormatter.date(from: dateJSON.string!)!
        return date
    }
    
}

class DataSender {
    func saveSessionData(session: SessionAttendance, completion: @escaping (Error?) -> Void) {
        var sessionData = Data()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        print("Encoded JSON starts here")
        sessionData = try! encoder.encode(session)
        
        var json: [String: AnyObject] = [String: AnyObject]()
        do {
            json = try JSONSerialization.jsonObject(with: sessionData, options: []) as! [String: AnyObject]
            print(json)
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            
        }
        let requestUrl = baseURL + "session/" + String(session.sessionId)
        CustomManager.manager.request(requestUrl, method: .post, parameters: json, encoding: JSONEncoding.default).validate().responseJSON
            { response in
                switch response.result {
                case .success(let value):
                    let jsonFormat = JSON(value)
                    print(jsonFormat)
                    completion(nil)
                case .failure(let error):
                    print(error)
                    completion(error)
                }
        }
    }
}

class Authentication {
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
        user.middleName = json["middleName"].string ?? ""
        user.lastName = json["lastName"].string ?? ""
        user.teacherId = json["teacherId"].int ?? -1
        return user
    }
}

class User {
    var existsOnServer: Bool!
    var emailAddress = ""
    var bearerToken = ""
    var teacherId = -1
    var firstName = ""
    var middleName = ""
    var lastName = ""
}

class SessionAttendance: Codable {
    public var students = [StudentAttendance]()
    public var classInfo = ClassInfo()
    public var sessionId = 0
    public var date = Date()
    
    enum CodingKeys: String, CodingKey {
        case classInfo
        case students
        case date
        case sessionId
    }
}

class StudentAttendance: Codable {
    public var name = ""
    public var studentId = 0
    public var attendanceStatusId = 0
    public var reasonId = 0
    
    enum CodingKeys: String, CodingKey {
        case name = "studentName"
        case studentId
        case attendanceStatusId
        case reasonId
    }
}

class ClassInfo: Codable {
    public var className = ""
    public var classId = 0
    public var classDescription = ""
    public var recName = ""
    public var primaryTeacherName = ""
    
    enum CodingKeys: String, CodingKey {
        case className
        case classId
        case classDescription
        case recName
        case primaryTeacherName
    }
}

class CustomManager: SessionManager {
    static public let manager = CustomManager.generateManager()
    class func generateManager()-> CustomManager {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        var test = currentUser
        defaultHeaders["Authorization"] = currentUser.bearerToken
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        let manager = CustomManager(configuration: configuration)
        return manager
    }
}

extension UIColor {
    public static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImage {
    public static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

