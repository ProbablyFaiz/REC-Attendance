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
    var teacherToCreate = Teacher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButton(sender:)))
        
        let teacherFirstName = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "First Name"
            }.onTextChanged { firstName in
                self.teacherToCreate.firstName = firstName
        }
        let teacherLastName = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "Last Name"
            }.onTextChanged { lastName in
                self.teacherToCreate.lastName = lastName
        }
        let teacherEmailAddress = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "Email Address"
            }.onTextChanged { emailAddress in
                self.teacherToCreate.emailAddress = emailAddress
        }
        let personalInfoSection = SectionFormer(rowFormer: teacherFirstName, teacherLastName, teacherEmailAddress).set(headerViewFormer: createHeader("Personal Info"))
        former.append(sectionFormer: personalInfoSection)
        
        let administratorSwitch = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Administrator"
            }.onSwitchChanged { isAdministrator in
                self.teacherToCreate.isAdministrator = isAdministrator
        }
        let classSelectionRow = LabelRowFormer<FormLabelCellWithAccessory>().configure { row in
            row.text = "Classes Taught"
            }.onSelected { row in
                
        }
        let section2 = SectionFormer(rowFormer: administratorSwitch, classSelectionRow).set(headerViewFormer: createHeader("Permissions"))
        former.append(sectionFormer: section2)
        
        
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

class FormLabelCellWithAccessory: FormLabelCell {
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
    }
}
