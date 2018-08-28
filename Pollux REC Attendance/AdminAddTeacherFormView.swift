//
//  AdminAddTeacher.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 8/17/18.
//  Copyright © 2018 Ibrahim Surani. All rights reserved.
//

import UIKit
import Former
import NotificationBannerSwift

class AdminAddTeacherFormView: FormViewController {
    var teacherToCreateOrEdit = Teacher()
    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarButton(sender:)))
        formerSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if editMode {
            navigationItem.title = "Edit Teacher"
        }
        if updatedClassesTaught.count > 0 {
            teacherToCreateOrEdit.classesTaught = updatedClassesTaught
            updatedClassesTaught = [ClassTerm]()
            (self.former.sectionFormers[1].rowFormers[2] as! LabelRowFormer<FormLabelCellWithAccessory>).configure { row in
                row.update()
                row.update { row in
                    if updatedSelectedCount == 0 {
                        row.text = "Classes Taught - " + String(teacherToCreateOrEdit.classesTaught.count) + " Selected"
                    }
                    else {
                        row.text = "Classes Taught - " + String(updatedSelectedCount) + " Selected"
                        updatedSelectedCount = 0
                        doGetClassesFromServer = false
                    }
                }
            }
        }
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
            }.onSwitchChanged { isAdministrator in
                self.teacherToCreateOrEdit.isAdministrator = isAdministrator
            }.configure { row in
                row.switched = self.teacherToCreateOrEdit.isAdministrator
        }
        let disableSwitch = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Disable Account?"
            $0.switchButton.isOn = self.teacherToCreateOrEdit.isDisabled
            }.onSwitchChanged { isDisabled in
                self.teacherToCreateOrEdit.isDisabled = isDisabled
            }.configure { row in
                row.switched = self.teacherToCreateOrEdit.isDisabled
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
        if !editMode {
            AdminDataManager.checkIfEmailIsDuplicate(emailAddress: teacherToCreateOrEdit.emailAddress) { doesExist, error in
                if error == nil {
                    if doesExist! {
                        let banner = NotificationBanner(title: "Error: Duplicate Email", subtitle: "This email is being used by a different account.", style: .danger)
                        banner.show()
                    }
                    else {
                        self.saveTeacher()
                    }
                }
                else {
                    let banner = NotificationBanner(title: "Error checking if email is duplicate", subtitle: error!.localizedDescription, style: .danger)
                    banner.show()
                }
            }
        }
        else {
            saveTeacher()
        }
        updatedSelectedCount = 0
        updatedClassesTaught = [ClassTerm]()
        doGetClassesFromServer = true
    }
    
    func saveTeacher() {
        AdminDataManager.saveTeacher(teacherToSave: teacherToCreateOrEdit, addNew: !editMode) { error in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let banner = NotificationBanner(title: "Error saving teacher", subtitle: error!.localizedDescription, style: .danger)
                banner.show()
            }
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if let teacherList = parent as? ManageTeacherTableView {
            updatedSelectedCount = 0
            updatedClassesTaught = [ClassTerm]()
            doGetClassesFromServer = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectClassesView = segue.destination as? SelectClassesTableView {
            selectClassesView.classTermsOfTeacher = teacherToCreateOrEdit.classesTaught
        }
    }
}

class FormLabelCellWithAccessory: FormLabelCell {
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
    }
}
