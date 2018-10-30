//
//  Constants.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

enum Constants {
    
    enum API {
        
        static let geoServiceBaseURL = URL(string: "https://geoip.nekudo.com/api/")!
        static let ipServiceBaseURL = URL(string: "https://api.ipify.org?format=json")!
    }
}
