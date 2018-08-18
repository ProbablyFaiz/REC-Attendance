//
//  scheduleViewController.swift
//  Pollux REC Attendance
//
//  Created by Ibrahim Surani on 1/6/18.
//  Copyright © 2018 Ibrahim Surani. All rights reserved.
//

import UIKit
import FSCalendar
import AZTabBar
import NotificationBannerSwift

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendarView: FSCalendar!
    var sessionList = [SessionAttendance]()
    @IBOutlet weak var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSessionList(month: Date())
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        calendarView.delegate = self
        calendarView.dataSource = self
    }
    
    func populateSessionList(month: Date) {
        let monthString = dateToMonthString(date: month)
        DataGetter.getSessionList(teacherId: currentUser.teacherId, monthAndYear: monthString) { sessionList, error in
            if sessionList != nil {
                self.sessionList = sessionList!
                self.sessionList.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                self.scheduleTableView.reloadData()
            }
            else {
                let banner = NotificationBanner(title: "Failed to get session list", subtitle: error!.localizedDescription, style: .danger)
                banner.show()
            }
        }
    }
    
    func dateToMonthString(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MM-yyyy"
        return df.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SessionScheduleCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SessionScheduleCell  else {
            fatalError("The dequeued cell is not an instance of SessionScheduleCell.")
        }
        cell.accessoryType = .disclosureIndicator
        
        let sessionInCell = sessionList[indexPath.row]
        cell.className.text = sessionInCell.classInfo.className
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        cell.sessionDate.text = dateFormatter.string(from: sessionInCell.date)
        dateFormatter.dateFormat = "h:mm a"
        cell.sessionTime.text = dateFormatter.string(from: sessionInCell.date)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sessionId = sessionList[indexPath.row].sessionId
        let attendanceController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClassTableView") as! ClassTableView
        currentSessionId = sessionId
        currentTabBar?.setViewController(attendanceController, atIndex: 1)
        currentTabBar?.setIndex(1)
        
    }
    
    //Change table contents for current month
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        populateSessionList(month: calendar.currentPage)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
