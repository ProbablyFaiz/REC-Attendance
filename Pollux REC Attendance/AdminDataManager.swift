//
//  AdminDataManager.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 10/30/19.
//  Copyright © 2019 Faiz Surani. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
                case .success(_): //_ replaces let value
                    completion(nil)
                case .failure(let error):
                    print(error)
                    completion(error)
                }
        }
    }
}
