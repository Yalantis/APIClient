//
//  ErrorProcessor.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import APIClient

final class ErrorProcessor: PluginType {
    
    func decorate(_ error: Error) -> Error {
        if let error = error as? CustomError {
            return error
        }
        if let executorError = error as? AlamofireExecutorError, let error = executorError.error {
            let nserror = error as NSError
            // handle reachability
            if nserror.code == NSURLErrorNotConnectedToInternet || nserror.code == NSURLErrorTimedOut {
                return CustomError.connection
            }
            
            return CustomError.unhandled(error: error)
        }
        
        return error
    }
    
    func processError(_ response: APIClient.HTTPResponse) -> Error? {
        guard let object = try? JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments),
            let error = CustomError(object: object) else {
                return CustomError.undefined
        }
        
        return error
    }
    
}
