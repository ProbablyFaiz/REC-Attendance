//
//  SessionScheduleCell.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 7/15/18.
//  Copyright © 2018 Ibrahim Surani. All rights reserved.
//

import UIKit

class SessionScheduleCell: UITableViewCell {

    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var sessionDate: UILabel!
    @IBOutlet weak var sessionTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
