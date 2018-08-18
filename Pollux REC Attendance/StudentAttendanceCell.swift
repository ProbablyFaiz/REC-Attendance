//
//  StudentAttendanceCell.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 1/1/18.
//  Copyright © 2018 Ibrahim Surani. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import McPicker

class StudentAttendanceCell: UITableViewCell, UITextFieldDelegate {

    let attendanceTypes = ["U","P", "A", "T"]
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var reasonTextField: UITextField!
    
    @IBOutlet weak var twicketAttendanceSegControl: TwicketSegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set up segment control
        twicketAttendanceSegControl.delegate = self
        twicketAttendanceSegControl.backgroundColor = UIColor.clear
        twicketAttendanceSegControl.setSegmentItems(attendanceTypes)
        twicketAttendanceSegControl.sliderBackgroundColor = UIColor.hexStringToUIColor(hex: "46B2FF")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension StudentAttendanceCell: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        if segmentIndex != 0 && segmentIndex != 1 {
            reasonTextField.isHidden = false
        }
        else {
            reasonTextField.isHidden = true
        }
    }
}
