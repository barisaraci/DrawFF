//
//  ViewController.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/19/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CACHING STUFF
        
        /*let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "isRegistered") != nil { // check if login cached
            let isRegistered = preferences.bool(forKey: "isRegistered")
            
            if (isRegistered) {
                progressBar.startAnimating()
                
                tfUsername.isHidden = true
                tfPassword.isHidden = true
                buttonLogin.isHidden = true
                registerButton.isHidden = true
                
                let username = preferences.string(forKey: "username")
                let password = preferences.string(forKey: "password")
                
                login(user: username!, pass: password!)
            }
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        buttonLogin.isHidden = true
        progressBar.startAnimating()
        
        let username = tfUsername.text
        let password = tfPassword.text
        
        login(user: username!, pass: password!)
    }
    
    func login(user: String, pass: String) {
        let json: [String: Any] = ["user": user, "pass": pass]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://www.barisaraci.com/drawff/query.php?action=login")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    /*self.tfUsername.isHidden = false
                    self.tfPassword.isHidden = false
                    self.registerButton.isHidden = false*/
                    self.buttonLogin.isHidden = false
                    self.progressBar.stopAnimating()
                    
                    self.showToast(message: "There is a problem connecting to server")
                }
                return
            }
            
            let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            self.processResponse(result: response, username: user, password: pass)
            
            DispatchQueue.main.async {
                /*self.tfUsername.isHidden = false
                self.tfPassword.isHidden = false
                self.registerButton.isHidden = false*/
                self.buttonLogin.isHidden = false
                self.progressBar.stopAnimating()
            }
        }
        
        task.resume()
    }
    
    func processResponse(result: String, username: String, password: String) {
        let userId = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (userId == "-1") {
            DispatchQueue.main.async {
                self.showToast(message: "The password is incorrect")
            }
        } else if (userId == "-2") {
            DispatchQueue.main.async {
                self.showToast(message: "The username could not be found")
            }
        } else {
            // CACHING STUFF
            
            /*let preferences = UserDefaults.standard
            
            if preferences.object(forKey: "isRegistered") == nil {
                preferences.setValue(true, forKey: "isRegistered")
                preferences.setValue(username, forKey: "username")
                preferences.setValue(password, forKey: "password")
                preferences.synchronize()
            }*/
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                vc.userId = userId
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickSignup(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        navigationController?.pushViewController(vc, animated: true)
    }


}

