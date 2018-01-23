//
//  ViewController.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var ipAddressTextField: UITextField!
    @IBOutlet private var dataTextView: UITextView!
    
    @IBAction private func findCurrentIP() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ipServiceNetworkClient
            .execute(request: IPAddressRequest())
            .continueWith(.mainThread) { [weak self] task in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let result = task.result {
                    self?.display(ipAddress: result)
                } else if let error = task.error {
                    self?.display(error: error)
                }
        }
    }
    
    @IBAction private func findData() {
        geoServiceNetworkClient
            .execute(request: IPAddressDataRequest(ipAddress: ipAddressTextField.text ?? ""))
            .continueWith(.mainThread) { [weak self] task in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let result = task.result {
                    self?.display(data: result)
                } else if let error = task.error {
                    self?.display(error: error)
                }
        }
    }
    
    private func display(error: Error) {
        dataTextView.text = error.localizedDescription
    }
    
    private func display(ipAddress: IPAddress) {
        ipAddressTextField.text = ipAddress.address
    }
    
    private func display(data: LocationMetaData) {
        dataTextView.text = "\(data)"
    }
}

extension ViewController: NetworkClientInjectable {}
