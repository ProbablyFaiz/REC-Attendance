//
//  AdminAddTeacher.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 8/17/18.
//  Copyright © 2018 Ibrahim Surani. All rights reserved.
//

import UIKit
import Former

class AdminAddTeacherFormView: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButton(sender:)))
        
        let teacherFirstName = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "First Name"
        }
        let teacherLastName = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Last Name"
        }
        let teacherEmailAddress = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Email Address"
        
        }
        let section = SectionFormer(rowFormer: teacherFirstName, teacherLastName).set(headerViewFormer: createHeader("Personal Info"))
        former.append(sectionFormer: section)
    }
    
    let createHeader: ((String) -> ViewFormer) = { text in
        return LabelViewFormer<FormLabelHeaderView>()
            .configure {
                $0.viewHeight = 40
                $0.text = text
        }
    }
    
    @objc func saveBarButton(sender: UIBarButtonItem) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }


}
