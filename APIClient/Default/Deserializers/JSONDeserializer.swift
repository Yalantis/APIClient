//
// Created by Eugene Andreyev on 7/8/16.
// Copyright (c) 2016 Eugene Andreyev. All rights reserved.
//

import Foundation

public class JSONDeserializer: Deserializer {
    
    public func deserialize(_ response: HTTPURLResponse, data: Data) throws -> AnyObject {
        do {
            return try JSONSerialization
                .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch {
            throw NetworkError.resourceDeserializationError
        }
    }
    
}
