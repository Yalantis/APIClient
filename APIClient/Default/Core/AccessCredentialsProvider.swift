//
//  AccessCredentialsProvider.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/24/18.
//

// FIXME: inappropriate place

import Foundation

// TODO: add proper documentation
public protocol AccessCredentialsProvider: class {
    
    var accessToken: String? { get set }
    var exchangeToken: String? { get set }
    
    func commitCredentialsUpdate(_ update: (AccessCredentialsProvider) -> Void)
    func invalidate()
    
}
