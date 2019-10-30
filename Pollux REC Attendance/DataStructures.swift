//
//  DataStructures.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 10/30/19.
//  Copyright © 2019 Faiz Surani. All rights reserved.
//

import Foundation

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
