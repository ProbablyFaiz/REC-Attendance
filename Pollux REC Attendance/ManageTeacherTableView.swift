//
//  ManageTeacherTableView.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 8/17/18.
//  Copyright © 2018 Faiz Surani. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class ManageTeacherTableView: UITableViewController {
    var teachers = [Teacher]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Add Icon"), style: .plain, target: self, action: #selector(addButton(sender:)))
        AdminDataManager.getTeacherList(teacherId: currentUser.teacherId) { teachers, error in
            if error == nil {
                self.teachers = teachers!
                self.tableView.reloadData()
            }
            else {
                let banner = NotificationBanner(title: "Failed to get teacher list", subtitle: error?.localizedDescription, style: .danger)
                banner.show()
            }
        }
    }

    @objc func addButton(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "manageTeacherToAddForm", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return teachers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "manageTeacherCell", for: indexPath) as? ManageTeacherCell  else {
            fatalError("The dequeued cell is not an instance of StudentAttendanceCell.")
        }
        cell.teacherNameLabel.text = teachers[indexPath.row].firstName + " " + teachers[indexPath.row].lastName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AdminDataManager.getTeacher(teacherId: teachers[indexPath.row].teacherId) { teacher, error in
            if error == nil {
                self.performSegue(withIdentifier: "manageTeacherToAddForm", sender: teacher!)
            }
            else {
                let banner = NotificationBanner(title: "Failed to get teacher", subtitle: error?.localizedDescription, style: .danger)
                banner.show()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let teacher = sender as? Teacher {
            let editForm = segue.destination as! AdminAddTeacherFormView
            editForm.editMode = true
            editForm.teacherToCreateOrEdit = teacher
        }
    }
    

}
