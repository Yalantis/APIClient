//
//  APIErrorProcessor.swift
//  RegistrationAndProfileFlow-Demo
//
//  Created by Eugene Andreyev on 6/27/16.
//  Copyright © 2016 Eugene Andreyev. All rights reserved.
//

import Foundation

public protocol APIErrorProcessing {
    
    func processErrorWithResponse(response: APIClient.HTTPResponse) -> ErrorType
    
}

public struct APIErrorProcessor: APIErrorProcessing {
    
    public func processErrorWithResponse(response: APIClient.HTTPResponse) -> ErrorType {
        switch response.0.statusCode {
        case 400: //  for bad formed request
            return APIError.ResourceBadRequest
        
        case 401: // if auth required
            return APIError.ResourceUnauthorizedClient
            
        case 403: // if user don't have premission to perfom an action
            return APIError.ResourceInvalidGrantType
            
        case 404:// if request element is not found. For example we try try to get photos collection and there is no photo colection in the app. Or we try to get user with id=2 and there is no such user. If we try to get existing collection and it is empty we should return 200 and emty array.
            return APIError.ElementNotFound
            
        case 409:// if data that sends clients conflicts with one storedn on the server. For example we try to save post that was prviously edited by another user.
            return APIError.ResourceInvalidData
            
        case 422:
            return APIError.UndefinedValidationError
            
        default:
            return APIError.Undefined
        }
    }
    
}
