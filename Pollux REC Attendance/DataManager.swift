//
//  DataManager.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 12/16/17.
//  Copyright © 2017 Faiz Surani. All rights reserved.
//
// TODO: Disable arbitrary loads before submission

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NotificationBannerSwift

let baseURL1 = "http://192.168.1.36:45458/api/rec"
let baseURL = "https://recwebapi20180817111320.azurewebsites.net/api/rec/"
//Testing Git on new machine

class SessionDataManager {
    
    static func getNearestSessionId(teacherId: Int, completion: @escaping (Int?, Error?) -> Void) {
        let requestUrl = baseURL + "session/nearestId"
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                var sessionIdJson = JSON(value)
                print("JSON: \(sessionIdJson)")
                completion(sessionIdJson.int, nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
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
    
    static func getSessionList(monthAndYear: String, completion: @escaping ([SessionAttendance]?, Error?) -> Void) {
        var sessionList = [SessionAttendance]()
        let requestUrl = baseURL + "sessionlist/" + String(currentUser.teacherId) + "&month=" + monthAndYear
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
    
    static func saveSessionData(session: SessionAttendance, completion: @escaping (Error?) -> Void) {
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

class AdminDataManager {
    
    static func getTeacher(teacherId: Int, completion: @escaping (Teacher?, Error?) -> Void) {
        let requestUrl = baseURL + "teacher/" + String(teacherId) + "&user=" + String(currentUser.teacherId)
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let teacherJson = JSON(value)
                print("JSON: \(teacherJson)")
                completion(parseTeacherJson(teacherJson, getAllInfo: true), nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func parseTeacherJson(_ teacherJson: JSON, getAllInfo: Bool) -> Teacher {
        let teacher = Teacher()
        teacher.teacherId = teacherJson["teacherId"].int ?? 0
        teacher.firstName = teacherJson["firstName"].stringValue
        teacher.lastName = teacherJson["lastName"].stringValue
        teacher.emailAddress = teacherJson["emailAddress"].stringValue
        
        if getAllInfo {
            teacher.isAdministrator = teacherJson["isAdministrator"].bool ?? false
            teacher.isDisabled = teacherJson["isDisabled"].bool ?? false
            teacher.classesTaught = parseClassTermListJson(teacherJson["classesTaught"])
        }
        return teacher
    }
    
    static func getTeacherList(teacherId: Int, completion: @escaping ([Teacher]?, Error?) -> Void) {
        let requestUrl = baseURL + "teacherList/" + String(teacherId)
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let teacherListJson = JSON(value)
                print("JSON: \(teacherListJson)")
                completion(parseTeacherListJson(teacherListJson), nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
        
    fileprivate static func parseTeacherListJson(_ teacherListJson: JSON) -> [Teacher] {
        var teachers = [Teacher]()
        for (_, teacherJson) in teacherListJson {
            teachers.append(parseTeacherJson(teacherJson, getAllInfo: false))
        }
        return teachers;
    }
    
    static func getClassTermList(teacherId: Int, completion: @escaping ([ClassTerm]?, Error?) -> Void) { //Class term for rec, not teacher. Teacher id used for convenience.
        let requestUrl = baseURL + "classTermList/" + String(teacherId)
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let classTermListJson = JSON(value)
                print("JSON: \(classTermListJson)")
                completion(parseClassTermListJson(classTermListJson), nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func parseClassTermListJson(_ classTermListJson: JSON) -> [ClassTerm] {
        var classTermList = [ClassTerm]()
        for (_, classTermJson) in classTermListJson {
            let classTerm = ClassTerm()
            classTerm.name = classTermJson["name"].stringValue
            classTerm.classTermId = classTermJson["classTermId"].int ?? 0
            classTermList.append(classTerm)
        }
        return classTermList
    }
    
    static func checkIfEmailIsDuplicate(emailAddress: String, completion: @escaping (Bool?, Error?) -> Void) {
        let requestUrl = baseURL + "emailIsDuplicate/" + emailAddress
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let isDuplicateJson = JSON(value)
                completion(isDuplicateJson.bool, nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    static func saveTeacher(teacherToSave: Teacher, addNew: Bool, completion: @escaping (Error?) -> Void) {
        var teacherData = Data()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        print("Encoded JSON starts here")
        teacherData = try! encoder.encode(teacherToSave)
        
        var json: [String: AnyObject] = [String: AnyObject]()
        do {
            json = try JSONSerialization.jsonObject(with: teacherData, options: []) as! [String: AnyObject]
            print(json)
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        var requestUrl = baseURL + "teacher/" + String(currentUser.teacherId) + "/"
        var requestType = HTTPMethod.post
        if addNew {
            requestUrl += "new"
            requestType = .put
        }
        else {
            requestUrl += "update"
        }
        CustomManager.manager.request(requestUrl, method: requestType, parameters: json, encoding: JSONEncoding.default).validate().responseData
            { response in
                switch response.result {
                case .success(let value):
                    completion(nil)
                case .failure(let error):
                    print(error)
                    completion(error)
                }
        }
    }
}

class User {
    var existsOnServer: Bool!
    var emailAddress = ""
    var bearerToken = ""
    var firstName = ""
    var lastName = ""
    var teacherId = 0
    var recId = 0
}

class Teacher: Codable {
    var teacherId = 0
    var firstName = ""
    var lastName = ""
    var emailAddress = ""
    var classesTaught = [ClassTerm]()
    var isAdministrator = false
    var isDisabled = false
    
    enum CodingKeys: String, CodingKey {
        case teacherId
        case firstName
        case lastName
        case emailAddress
        case classesTaught
        case isAdministrator
    }
}

class ClassTerm: Codable {
    var classTermId = 0
    var name = "Class (Term)"
    var classDescription = ""
    var operation: String?
    
    enum CodingKeys: String, CodingKey {
        case classTermId
        case name
        case classDescription
        case operation
    }
}

class SessionAttendance: Codable {
    var students = [StudentAttendance]()
    var classInfo = ClassInfo()
    var sessionId = 0
    var date = Date()
    
    enum CodingKeys: String, CodingKey {
        case classInfo
        case students
        case date
        case sessionId
    }
}

class StudentAttendance: Codable {
    var name = ""
    var studentId = 0
    var attendanceStatusId = 0
    var reasonId = 0
    
    enum CodingKeys: String, CodingKey {
        case name = "studentName"
        case studentId
        case attendanceStatusId
        case reasonId
    }
}

class ClassInfo: Codable {
    var className = ""
    var classId = 0
    var classDescription = ""
    var recName = ""
    var primaryTeacherName = ""
    
    enum CodingKeys: String, CodingKey {
        case className
        case classId
        case classDescription
        case recName
        case primaryTeacherName
    }
}

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

extension NotificationBanner {
    public static func showErrorBanner(title: String, error: Error?) {
        let banner = NotificationBanner(title: title, subtitle: error!.localizedDescription, style: .danger)
        banner.show()
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

