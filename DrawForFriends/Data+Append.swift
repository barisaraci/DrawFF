//
//  NSMutableData+Append.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/30/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import Foundation

extension Data {
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }

}
