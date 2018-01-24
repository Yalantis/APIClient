//
//  CountryMetaData.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import ObjectMapper

struct CountryMetaData: ImmutableMappable {
    
    let name: String
    let code: String
    
    init(map: Map) throws {
        name = try map.value("name")
        code = try map.value("code")
    }
    
}
