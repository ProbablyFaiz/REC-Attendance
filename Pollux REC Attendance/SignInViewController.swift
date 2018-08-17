//
//  ViewController.swift
//  Pollux REC Attendance
//
//  Created by Faiz Surani on 12/16/17.
//  Copyright © 2017 Faiz Surani. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import McPicker
import Simplicity

var currentUser = User()

class SignInViewController: UIViewController {
    
    @IBOutlet weak var googleSignIn: UIButton!
    
    @IBAction func googleSignIn(_ sender: Any) {
        Simplicity.login(Google()) { accessToken, error in
            if error == nil {
                Authentication.validateLoginAndGetInfo(accessToken: accessToken!) { user, error in
                    if error == nil {
                        currentUser = user!
                        let defaults = UserDefaults.standard
                        defaults.set(currentUser.bearerToken, forKey: "BearerToken")
                        
                        self.performSegue(withIdentifier: "signInToTabController", sender: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults()
        if let storedToken = defaults.string(forKey: "BearerToken") {
            currentUser.bearerToken = storedToken
            print(storedToken)
            self.performSegue(withIdentifier: "signInToTabController", sender: nil)
        }
        
        self.googleSignIn.alpha =  0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.googleSignIn.alpha = 1
        }) 
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


