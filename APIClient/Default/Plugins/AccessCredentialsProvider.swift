//
//  AccessCredentialsProvider.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

import Foundation

/// Describes required entity for `RequestDecorationPlugin`
public protocol AccessCredentialsProvider: class {
    
    var accessToken: String? { get set }
    var exchangeToken: String? { get set }
    
    /// Method for update your credential
    ///
    /// - Parameter update: closure with new credentials
    func commitCredentialsUpdate(_ update: (AccessCredentialsProvider) -> Void)
    
    /// Called in case of not successful update
    func invalidate()
}
