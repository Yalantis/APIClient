//
//  LocationMetaData.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import ObjectMapper

struct LocationMetaData: ImmutableMappable {
    
    let city: String?
    let country: CountryMetaData?
    
    init(map: Map) throws {
        city = try? map.value("city")
        country = try? map.value("country")
    }
    
}
