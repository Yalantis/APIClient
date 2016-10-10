//
//  RequestDecorator.swift
//  CuratumPlatform
//
//  Created by Eugene Andreyev on 8/1/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//
public protocol RequestDecorator {
    
    func decoratedRequest(from request: APIRequest) -> APIRequest
    
}
