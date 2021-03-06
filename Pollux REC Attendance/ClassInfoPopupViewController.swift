//
//  ClassInfoPopupViewController.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 1/5/18.
//  Copyright © 2018 Faiz Surani. All rights reserved.
//

import UIKit
import MIBlurPopup
import LGButton

class ClassInfoPopupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var currentSession = SessionAttendance()
    
    @IBOutlet weak var popupInfoContainerView: UIView!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var sessionDateLabel: UILabel!
    
    
    @IBAction func closeViewLGButton(_ sender: LGButton) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        classNameLabel.text = currentSession.classInfo.className
        let mainTeacher = currentSession.classInfo.primaryTeacherName
        teacherLabel.text = "Main Teacher: " + mainTeacher
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        sessionDateLabel.text = "Session Date: " + df.string(from: currentSession.date)
        studentTableView.allowsSelection = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSession.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = currentSession.students[indexPath.row].name
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

extension ClassInfoPopupViewController: MIBlurPopupDelegate {
    
    var popupView: UIView {
        return popupInfoContainerView ?? UIView()
    }
    
    var blurEffectStyle: UIBlurEffect.Style {
        return UIBlurEffect.Style.extraLight
    }
    
    var initialScaleAmmount: CGFloat {
        return 0.8
    }
    
    var animationDuration: TimeInterval {
        return 0.7
    }
    
}

class studentTableViewCellInInfoPopup : UITableViewCell {
    
}
