//
//  ViewController.swift
//  ParseChat
//
//  Created by Kay Lab on 5/6/19.
//  Copyright © 2019 Darrel Muonekwu. All rights reserved.
// pm install -g parse-dashboard
// parse-dashboard --appId Parstagram --masterKey myMasterKey --serverURL "https://stark-river-64085.herokuapp.com/parse"

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var useranameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onSignUp(_ sender: Any) {
        
        if usernameAndPasswordNotEmpty() {
            let newUser = PFUser()
            newUser.username = useranameTextField.text!.lowercased()
            newUser.password = passwordTextField.text!

            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    print("There was an error. \(error.localizedDescription)")
                    
                } else {
                    self.performSegue(withIdentifier: Segues.authenticated , sender: nil)
                    print("User has Logged In!")
                }
            }
        }
    }

    
    @IBAction func onLogIn(_ sender: UIButton) {
        let username = useranameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: Segues.authenticated, sender: nil)
                print("User has signed Up!")
            } else {
                print("User cannot be loggedin: \(error?.localizedDescription ?? "idk what happened")")
            }
        }
    }

    
    func usernameAndPasswordNotEmpty() -> Bool {
        if (useranameTextField.text != "") && (passwordTextField.text != "") {
            return true
        } else {
            return false
        }
    }
    
    // NEXT TWO FUNCTIONS DISMISS THE KEY BOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        useranameTextField.resignFirstResponder()
        return true
    }
}

