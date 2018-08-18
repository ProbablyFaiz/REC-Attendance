//
//  TabBarController.swift
//  
//
//  Created by Ibrahim Surani on 8/12/18.
//

import UIKit
import AZTabBar

class TabBarController: UIViewController {

    var tabController: AZTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var icons = [UIImage]()
        icons.append(#imageLiteral(resourceName: "Calendar Icon"))
        icons.append(#imageLiteral(resourceName: "Attendance Icon"))
        icons.append(#imageLiteral(resourceName: "Settings Icon"))
        tabController = AZTabBarController.insert(into: self, withTabIcons: icons, andSelectedIcons: icons)
        tabController.delegate = self
        
        let scheduleController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScheduleViewController")
        let attendanceController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClassTableViewNavController")
        let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewNavController")
        tabController.setViewController(scheduleController, atIndex: 0)
        tabController.setViewController(attendanceController, atIndex: 1)
        tabController.setViewController(settingsController, atIndex: 2)
        
        tabController.animateTabChange = true
        
        tabController.defaultColor = lightBlueBackgroundColor
        tabController.selectedColor = .white //To take care of highlighted default index
        
        tabController.buttonsBackgroundColor = .white
        tabController.separatorLineColor = lightBlueBackgroundColor
        tabController.selectionIndicatorColor = lightBlueBackgroundColor
        
        tabController.highlightedBackgroundColor = lightBlueBackgroundColor
        tabController.highlightColor = .white
        
        //tabController.setTitle("Schedule", atIndex: 0)
        //tabController.setTitle("Attendance", atIndex: 1)
        //tabController.setTitle("Settings", atIndex: 2)
        
        tabController.onlyShowTextForSelectedButtons = false
        tabController.tabBarHeight = 55
        
        tabController.highlightButton(atIndex: 1)
        tabController.setIndex(1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension TabBarController: AZTabBarDelegate{
    func tabBar(_ tabBar: AZTabBarController, statusBarStyleForIndex index: Int) -> UIStatusBarStyle {
        return (index % 2) == 0 ? .default : .lightContent
    }
    
    func tabBar(_ tabBar: AZTabBarController, shouldAnimateButtonInteractionAtIndex index: Int) -> Bool {
        return false
    }
    func tabBar(_ tabBar: AZTabBarController, didSelectTabAtIndex index: Int) {
        if (index == 1) {
            tabController.selectedColor = .white
        }
        else {
            tabController.selectedColor = lightBlueBackgroundColor
        }
    }
    /*
    func tabBar(_ tabBar: AZTabBarController, didMoveToTabAtIndex index: Int) {
        print("didMoveToTabAtIndex \(index)")
    }
    
    
    
    func tabBar(_ tabBar: AZTabBarController, willMoveToTabAtIndex index: Int) {
        print("willMoveToTabAtIndex \(index)")
    }
    
    func tabBar(_ tabBar: AZTabBarController, didLongClickTabAtIndex index: Int) {
        print("didLongClickTabAtIndex \(index)")
    }
    */
}
