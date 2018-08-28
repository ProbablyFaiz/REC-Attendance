//
//  SelectClassesTableView.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 8/17/18.
//  Copyright © 2018 Faiz Surani. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Former

var updatedClassesTaught = [ClassTerm]()
var updatedSelectedCount = 0
var doGetClassesFromServer = true

class SelectClassesTableView: UITableViewController {
    var classTerms = [ClassTerm]()
    var classTermsOfTeacher = [ClassTerm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if doGetClassesFromServer {
            AdminDataManager.getClassTermList(teacherId: currentUser.teacherId) { classTerms, error in
                if error == nil {
                    self.classTerms = classTerms!
                    updatedSelectedCount = self.classTerms.count
                    let classTermIds = self.classTerms.map { $0.classTermId }
                    let classTermIdsOfTeacher = self.classTermsOfTeacher.map { $0.classTermId }
                    self.tableView.reloadData()
                    updatedClassesTaught = self.classTerms
                    for i in 0 ..< self.classTerms.count {
                        if classTermIdsOfTeacher.contains(classTermIds[i]) { //FIX
                            self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .none)
                        }
                    }
                }
                else {
                    let banner = NotificationBanner(title: "Failed to get class terms", subtitle: error?.localizedDescription, style: .danger)
                    banner.show()
                }
            }
        }
        else {
            classTerms = updatedClassesTaught
            let classTermIds = self.classTerms.map { $0.classTermId }
            let classTermIdsOfTeacher = self.classTermsOfTeacher.map { $0.classTermId }
            for i in 0 ..< self.classTerms.count {
                if classTermIdsOfTeacher.contains(classTermIds[i]) {
                    
                }
                if let index = classTermIdsOfTeacher.index(of: classTermIds[i]) {
                    if classTermsOfTeacher[index].operation != "Delete" {
                        self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .none)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let classTermIdsOfTeacher = self.classTermsOfTeacher.map { $0.classTermId }
        let classTermIds = self.classTerms.map { $0.classTermId }
        if let index = classTermIdsOfTeacher.index(of: classTermIds[indexPath.row]) {
            classTermsOfTeacher[index].operation = nil
        }
        else {
            classTermsOfTeacher.append(classTerms[indexPath.row])
        }
        updatedSelectedCount = updatedSelectedCount + 1
        updatedClassesTaught = classTermsOfTeacher
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let classTermIdsOfTeacher = self.classTermsOfTeacher.map { $0.classTermId }
        let classTermIds = self.classTerms.map { $0.classTermId }
        if let index = classTermIdsOfTeacher.index(of: classTermIds[indexPath.row]) {
            classTermsOfTeacher[index].operation = "Delete"
            updatedSelectedCount = updatedSelectedCount - 1
        }
        updatedClassesTaught = classTermsOfTeacher
        
        return indexPath
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classTerms.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "selectClassesCell", for: indexPath) as? SelectClassesCell else {
            fatalError("The dequeued cell is not an instance of selectClassesCell.")
        }
        cell.classTermNameLabel.text = classTerms[indexPath.row].name
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
