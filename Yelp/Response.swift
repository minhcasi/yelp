//
//  Response.swift
//  Yelp
//
//  Created by minh on 11/22/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import Foundation

class Response: NSObject {
    let total: Int?
    let businesses: [Business]!
    
    init(list: [Business]!, total: Int) {
        self.total = total
        self.businesses = list
    }
}