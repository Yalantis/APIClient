//
// Created by Eugene Andreyev on 7/8/16.
// Copyright (c) 2016 Eugene Andreyev. All rights reserved.
//

import Foundation

public class JSONDeserializer: Deserializer {

    public func deserialize(response: NSHTTPURLResponse, data: NSData) throws -> AnyObject {
        do {
            return try NSJSONSerialization
            .JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            throw APIError.ResourceDeserialization
        }
    }

}
