//
//  ErrorPreprocessorPlugin.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 2/23/17.
//  Copyright © 2017 Eugene Andreyev. All rights reserved.
//

public final class ErrorPreprocessorPlugin: PluginType {
    
    private let errorPreprocessor: ErrorProcessing
    
    public init(errorPreprocessor: ErrorProcessing) {
        self.errorPreprocessor = errorPreprocessor
    }
    
    public func processError(_ response: APIClient.HTTPResponse) -> Error? {
        return errorPreprocessor.processError(using: response)
    }
}
