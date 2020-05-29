//
//  HaltingRequestsService.swift
//  APIClient
//
//  Created by Roman Kyrylenko on 10/17/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation

final class HaltingRequestsService: NSObject {
    
    private struct HaltingRequest {
        
        let execute: () -> Void
        let cancel: () -> Void
    }
    
    private let supportHalting: Bool
    private let supportCancelling: Bool
    
    private var shouldHalt = false
    private var shouldCancel = false
    private var authTimerStarted = false
    
    private var haltingRequests: [HaltingRequest] = []
    
    init(plugins: [PluginType]) {
        let restorationPlugin = plugins.first(where: { $0 is RestorationTokenPlugin }) as? RestorationTokenPlugin
        let authorizationPlugin = plugins.first(where: { $0 is AuthorizationPlugin }) as? AuthorizationPlugin
        supportHalting = restorationPlugin?.shouldHaltRequestsTillResolve ?? false
        supportCancelling = authorizationPlugin?.shouldCancelRequestIfFailed ?? false
        
        super.init()
        
        if restorationPlugin == nil {
            /// we need to know when authorization fails at least from one of the plugins
            authorizationPlugin?.delegate = self
        }
        restorationPlugin?.delegate = self
    }
    
    func shouldProceed(with request: APIRequest) -> Bool {
        guard let `request` = request as? AuthorizableRequest, request.authorizationRequired else {
            return true
        }
        return !shouldHalt && !shouldCancel
    }
    
    func add(execution: @escaping () -> Void, cancellation: @escaping () -> Void) {
        if !shouldHalt && shouldCancel && authTimerStarted {
            cancellation()
        } else {
            haltingRequests.append(HaltingRequest(execute: execution, cancel: cancellation))
        }
    }
    
    @objc func cancelRequests() {
        shouldHalt = false
        shouldCancel = false
        authTimerStarted = false
        haltingRequests.forEach { $0.cancel() }
        haltingRequests.removeAll()
    }
}

extension HaltingRequestsService: AuthorizationPluginDelegate {
    
    func reachAuthorizationError() {
        shouldCancel = supportCancelling
        if !authTimerStarted && shouldCancel {
            authTimerStarted = true
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelRequests), object: nil)
            perform(#selector(cancelRequests), with: nil, afterDelay: AuthorizationPlugin.requestsCancellingTimespan)
        }
    }
}

extension HaltingRequestsService: RestorationTokenPluginDelegate {
    
    func failedToRestore() {
        shouldHalt = false
        shouldCancel = supportCancelling
    }
    
    func reachUnauthorizedError() {
        shouldHalt = supportHalting
    }
    
    func restored() {
        shouldHalt = false
        shouldCancel = false
        haltingRequests.forEach { $0.execute() }
        haltingRequests.removeAll()
    }
}
