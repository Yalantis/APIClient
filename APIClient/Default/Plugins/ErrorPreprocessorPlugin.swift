//
//  ErrorPreprocessorPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/23/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

import BoltsSwift

public final class ErrorPreprocessorPlugin: PluginType {
    
    private let errorPreprocessor: APIErrorProcessing
    
    public init(errorPreprocessor: APIErrorProcessor) {
        self.errorPreprocessor = errorPreprocessor
    }
    
    public func processError(_ response: APIClient.HTTPResponse) -> Error? {
        return errorPreprocessor.processError(using: response)
    }
    
}
