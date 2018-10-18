//
//  HaltingRequestsService.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/17/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

final class HaltingRequestsService {
    
    private struct HaltingRequest {
        
        let execute: () -> Void
        let cancel: () -> Void
    }
    
    private let supportHalting: Bool
//    private let supportCancelling: Bool
    
    private var shouldHalt = false
//    private var shouldCancel = false
    private var haltingRequests: [HaltingRequest] = []
    
    init(plugins: [PluginType]) {
        let restorationPlugin = plugins.first(where: { $0 is RestorationTokenPlugin }) as? RestorationTokenPlugin
        supportHalting = restorationPlugin?.shouldHaltRequestsTillResolve ?? false
        restorationPlugin?.delegate = self
//        supportCancelling = (plugins.first(where: { $0 is AuthorizationPlugin }) as? AuthorizationPlugin)?.shouldCancelRequestIfFailed ?? false
    }
    
    func shouldProceed(with request: APIRequest) -> Bool {
        guard let `request` = request as? AuthorizableRequest, request.authorizationRequired else {
            return true
        }
        
        return !shouldHalt// && !shouldCancel
    }
    
    func add(exectuion: @escaping () -> Void, cancellation: @escaping () -> Void) {
        haltingRequests.append(HaltingRequest(execute: exectuion, cancel: cancellation))
    }
}

extension HaltingRequestsService: RestorationTokenPluginDelegate {
    
    func failedToRestore() {
        shouldHalt = false
//        shouldCancel = supportCancelling
    }
    
    func reachUnauthorizedError() {
        shouldHalt = supportHalting
    }
    
    func restored() {
        shouldHalt = false
        haltingRequests.forEach { $0.execute() }
        haltingRequests.removeAll()
    }
}
