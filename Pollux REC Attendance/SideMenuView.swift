//
//  SideMenuView.swift
//  
//
//  Created by Ibrahim Surani on 1/4/18.
//

import UIKit
import SideMenu
import ZFRippleButton

class SideMenuView: UITableViewController {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileCellButton: ZFRippleButton!
    @IBOutlet weak var scheduleCellButton: ZFRippleButton!
    @IBOutlet weak var attendanceCellButton: ZFRippleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSetup()
    }
    
    fileprivate func tableSetup() {
        tableViewSetup()
        profileMenuCellSetup()
        setupZFRippleButton(button: scheduleCellButton)
        setupZFRippleButton(button: attendanceCellButton)
    }
    
    @IBAction func scheduleCellButton(_ sender: Any) {
        cellButtonAction(controllerToSegueToId: "ScheduleViewController")   }
    @IBAction func attendanceCellButton(_ sender: Any) {
        cellButtonAction(controllerToSegueToId: "ClassTableView")   }
    
    //presentingViewController doesn't return properly, check fails. TODO
    fileprivate func cellButtonAction(controllerToSegueToId: String) {
        print(self.presentingViewController?.restorationIdentifier)
        if (presentingViewController?.restorationIdentifier == controllerToSegueToId) {
            dismiss(animated: true, completion: nil)
        }
        else {
            let controllerToSegueTo = storyboard!.instantiateViewController(withIdentifier: controllerToSegueToId)
            navigationController?.pushViewController(controllerToSegueTo, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func tableViewSetup() {
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsMake(75, 0, 0, 0)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "Blue Gradient"))
    }

    fileprivate func profileMenuCellSetup() {
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderColor = UIColor.white.cgColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
        profilePictureView.clipsToBounds = true
        profilePictureView.image = #imageLiteral(resourceName: "Sample Profile Picture")
        
        //let currentTeacher = classDataForCurrentLogin?.currentTeacher
        //profileNameLabel.text = (currentTeacher?.firstName)! + " " + (currentTeacher?.lastName)!
        setupZFRippleButton(button: profileCellButton)
    }
    
    fileprivate func setupZFRippleButton(button: ZFRippleButton) {
        button.ripplePercent = 10
        button.buttonCornerRadius = 2
        button.rippleOverBounds = true
        button.rippleColor = UIColor(patternImage: #imageLiteral(resourceName: "Blue Gradient"))
        button.rippleBackgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Blue Gradient"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        }
            
        else if indexPath.row == 1 {
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}


