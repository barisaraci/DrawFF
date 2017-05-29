//
//  SignupViewController.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/27/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfPassword2: UITextField!
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickSignup(_ sender: Any) {
        buttonSignup.isHidden = true
        progressBar.startAnimating()
        
        let username = tfUsername.text
        let password = tfPassword.text
        let password2 = tfPassword2.text
        
        signup(user: username!, pass1: password!, pass2: password2!)
    }
    
    func signup(user: String, pass1: String, pass2: String) {
        let json: [String: Any] = ["user": user, "pass1": pass1, "pass2": pass2]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://www.barisaraci.com/drawff/query.php?action=signup")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    self.buttonSignup.isHidden = false
                    self.progressBar.stopAnimating()
                    
                    self.showToast(message: "There is a problem connecting to server")
                }
                return
            }
            
            let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            self.processResponse(result: response)
            
            DispatchQueue.main.async {
                self.buttonSignup.isHidden = false
                self.progressBar.stopAnimating()
            }
        }
        
        task.resume()
    }
    
    func processResponse(result: String) {
        let reqResult = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (reqResult == "1") {
            DispatchQueue.main.async {
                self.showToast(message: "You have successfully signed up")
                
            }
            let timer = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: timer) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            DispatchQueue.main.async {
                self.showToast(message: reqResult)
            }
        }
    }

}
