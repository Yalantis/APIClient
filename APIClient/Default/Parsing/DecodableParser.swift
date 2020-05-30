//
//  DecodableParser.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/19/18.
//

import Foundation

public let defaultDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(iso8601Formatter)
    return decoder
}()

public let iso8601Formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
}()

public final class DecodableParser<T: Decodable>: KeyPathParser, ResponseParser {
    
    public typealias Representation = T
    
    public let decoder: JSONDecoder
    
    public init(keyPath: String? = nil, decoder: JSONDecoder = defaultDecoder) {
        self.decoder = decoder

        super.init(keyPath: keyPath)
    }
    
    public func parse(_ object: AnyObject) -> Result<T, NetworkClientError.SerializationError> {
        do {
            let value = try valueForKeyPath(in: object)
            let data = try JSONSerialization.data(withJSONObject: value)
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)
        } catch let error {
            return .failure(NetworkClientError.SerializationError.parsing(error))
        }
    }
}
