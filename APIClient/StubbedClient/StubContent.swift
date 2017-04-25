//
//  APIRequest+Stub.swift
//  APIClient
//
//  Created by Anton Vodolazkyi on 2/28/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

public enum StubContent {
    
    case jsonFile(path: String)
    case jsonUrl(url: URL)
    case data(data: Data)
    case json(object: Any)
    
}
