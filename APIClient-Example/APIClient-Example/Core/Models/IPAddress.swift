//
//  IPAddress.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import ObjectMapper

struct IPAddress {
    
    let address: String
    
}

extension IPAddress: ImmutableMappable {

    init(map: Map) throws {
        address = try map.value("ip")
    }

}

