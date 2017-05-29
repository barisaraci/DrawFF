//
//  ProfileViewCell.swift
//  DrawForFriends
//
//  Created by Baris Araci on 5/1/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {
    
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var viewImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
