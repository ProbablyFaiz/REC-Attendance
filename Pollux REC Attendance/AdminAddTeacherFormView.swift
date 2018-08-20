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
    var teacherToCreateOrEdit = Teacher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButton(sender:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        formerSetup()
    }
    
    func formerSetup() {
        let teacherFirstName = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "First Name"
            $0.text = teacherToCreateOrEdit.firstName
            }.onTextChanged { firstName in
                self.teacherToCreateOrEdit.firstName = firstName
        }
        let teacherLastName = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "Last Name"
            $0.text = teacherToCreateOrEdit.lastName
            }.onTextChanged { lastName in
                self.teacherToCreateOrEdit.lastName = lastName
        }
        let teacherEmailAddress = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "Email Address"
            $0.text = teacherToCreateOrEdit.emailAddress
            }.onTextChanged { emailAddress in
                self.teacherToCreateOrEdit.emailAddress = emailAddress
        }
        let personalInfoSection = SectionFormer(rowFormer: teacherFirstName, teacherLastName, teacherEmailAddress).set(headerViewFormer: createHeader("Personal Info"))
        former.append(sectionFormer: personalInfoSection)
        
        let classSelectionRow = LabelRowFormer<FormLabelCellWithAccessory>().configure { row in
            row.text = "Classes Taught - " + String(teacherToCreateOrEdit.classesTaught.count) + " Selected"
            }.onSelected { row in
                self.performSegue(withIdentifier: "addTeacherToSelectClass", sender: self)
        }
        let administratorSwitch = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Administrator?"
            $0.switchButton.isOn = self.teacherToCreateOrEdit.isAdministrator
            }.onSwitchChanged { isAdministrator in
                self.teacherToCreateOrEdit.isAdministrator = isAdministrator
        }
        let disableSwitch = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Disable Account?"
            $0.switchButton.isOn = self.teacherToCreateOrEdit.isDisabled
            }.onSwitchChanged { isDisabled in
                self.teacherToCreateOrEdit.isDisabled = isDisabled
        }
        let section2 = SectionFormer(rowFormer: administratorSwitch, disableSwitch, classSelectionRow).set(headerViewFormer: createHeader("Permissions"))
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
        //Check if email is duplicate
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
