//
//  DataManager.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 12/16/17.
//  Copyright © 2017 Faiz Surani. All rights reserved.
//
// TODO: Disable arbitrary loads before submission

import Foundation
import Alamofire
import SwiftyJSON

let baseURL1 = "http://192.168.1.36:45458/api/rec"
let baseURL = "https://recwebapi20180817111320.azurewebsites.net/api/rec/"

class SessionDataManager {
    
    static func getNearestSessionId(teacherId: Int, completion: @escaping (Int?, Error?) -> Void) {
        let requestUrl = baseURL + "session/nearestId"
        
        CustomManager.manager.request(requestUrl, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let sessionIdJson = JSON(value)
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
    
    static func jsonToDate(_ dateJSON: JSON) -> Date { //TODO: Fix this
        var date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date = dateFormatter.date(from: dateJSON.string!)!
        return date
    }    
}



