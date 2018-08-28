//
//  ClassTableView.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 12/16/17.
//  Copyright © 2017 Faiz Surani. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import McPicker
import MIBlurPopup
import NotificationBannerSwift

var currentSessionId: Int?

class ClassTableView: UITableViewController {
    
    var reasonArray = [String]()
    var currentSession = SessionAttendance()
    var students = [StudentAttendance]()
    
    @IBOutlet weak var classTitle: UINavigationItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBAction func saveBarButton(_ sender: Any) {
        SessionDataManager.saveSessionData(session: getSessionForSaving()) { error in }
        saveBarButton.isEnabled = false
    }
    
    @IBAction func infoBarButton(_ sender: Any) {
        performSegue(withIdentifier: "classInfoPopupSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSession() { error in
            if error != nil {
                let banner = NotificationBanner(title: "Error finding a session on the server", subtitle: error!.localizedDescription, style: .danger)
                banner.show()
            }
        }
    }
    
    private func basicSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshTable(sender:)), for: .valueChanged)
        
        reasonArray = ["Pick Reason", "None Given", "Academic", "Sports", "Extracurriculur", "Illness", "Other"]
        saveBarButton.isEnabled = false
        tableView.allowsSelection = false
    }
    
    private func getSession(completion: @escaping (Error?) -> Void) {
        if currentSessionId == nil {
            SessionDataManager.getNearestSessionId(teacherId: currentUser.teacherId) { sessionId, error in
                if error == nil && sessionId != nil {
                    currentSessionId = sessionId
                    SessionDataManager.getSessionData(sessionId: currentSessionId!) { sessionData, error in
                        if let sessionAttendance = sessionData {
                            self.currentSession = sessionAttendance
                            self.students = self.currentSession.students
                            self.classTitle.title = self.currentSession.classInfo.className
                            self.tableView.reloadData()
                            completion(nil)
                        }
                        else {
                            let banner = NotificationBanner(title: "Failed to get session data", subtitle: error!.localizedDescription, style: .danger)
                            banner.show()
                            completion(error)
                        }
                    }
                }
                else if sessionId == nil && error == nil {
                    let banner = NotificationBanner(title: "Could not find a session", subtitle: "Try checking your schedule to see if you have any.", style: .danger)
                    banner.show()
                    completion(nil)
                }
                else {
                    completion(error)
                }
            }
        }
        else {
            SessionDataManager.getSessionData(sessionId: currentSessionId!) { sessionData, error in
                if let sessionAttendance = sessionData {
                    self.currentSession = sessionAttendance
                    self.students = self.currentSession.students
                    self.classTitle.title = self.currentSession.classInfo.className
                    self.tableView.reloadData()
                    completion(nil)
                }
                else {
                    let banner = NotificationBanner(title: "Failed to get session data", subtitle: error!.localizedDescription, style: .danger)
                    banner.show()
                    completion(error)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        guard let popUpViewController = segue.destination as? ClassInfoPopupViewController else { return }
        popUpViewController.currentSession = currentSession
    }
    
    func getSessionForSaving() -> SessionAttendance {
        let session = SessionAttendance()
        for row in 0 ..< students.count {
            if students[row].attendanceStatusId <= 1 {
                students[row].reasonId = 0
            }
        }
        session.students = students
        session.sessionId = currentSession.sessionId
        return session
    }
   
}

extension ClassTableView {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "StudentAttendanceCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StudentAttendanceCell  else {
            fatalError("The dequeued cell is not an instance of StudentAttendanceCell.")
        }
        
        let studentInCell = students[indexPath.row]
        cell.studentNameLabel.text = studentInCell.name
        let statusId = students[indexPath.row].attendanceStatusId
        
        cell.twicketAttendanceSegControl.animationDuration = 0
        cell.twicketAttendanceSegControl.removeTarget(self, action: #selector(self.segmentChanged(sender:)), for: .valueChanged)
        if statusId == 1 || statusId == 2 || statusId == 3 {
            cell.twicketAttendanceSegControl.move(to: statusId)
        }
        cell.twicketAttendanceSegControl.animationDuration = 0.2
        
        if cell.twicketAttendanceSegControl.selectedSegmentIndex <= 1 {
            cell.reasonTextField.isHidden = true
        }
        
        cell.twicketAttendanceSegControl.tag = indexPath.row
        cell.twicketAttendanceSegControl.addTarget(self, action: #selector(self.segmentChanged(sender:)), for: .valueChanged)
        
        cell.reasonTextField.tag = indexPath.row
        cell.reasonTextField.delegate = self
    
        cell.reasonTextField.text = reasonArray[studentInCell.reasonId]
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ClassTableView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //TODO: Fetch reasons from DB instead
        let reasonList = [reasonArray]
        let currentText = textField.text
        
        let mcp = McPicker(data: reasonList)
        mcp.pickerSelectRowsForComponents = [0: [students[textField.tag].reasonId : false]]
        mcp.showAsPopover(fromViewController: self, sourceView: tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)), sourceRect: nil, barButtonItem: nil, doneHandler: { (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                textField.text = name
                let reasonId = self.reasonArray.index(of: name)
                self.students[textField.tag].reasonId = reasonId ?? 0
            }
            if textField.text != currentText {
                self.saveBarButton.isEnabled = true
            }
        })
        
        return false
    }
    
    @objc func segmentChanged(sender: TwicketSegmentedControl) {
        students[sender.tag].attendanceStatusId = sender.selectedSegmentIndex
        saveBarButton.isEnabled = true
    }
    
    @objc func refreshTable(sender: UIRefreshControl) {
        getSession { error in
            self.refreshControl!.endRefreshing()
            if (error != nil) {
                print("Refresh failed")
            }
        }
    }
    
}



