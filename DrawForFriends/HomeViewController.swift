//
//  HomeViewController.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/30/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {
    
    var userId : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedIndex = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
