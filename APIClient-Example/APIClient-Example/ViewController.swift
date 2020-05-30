//
//  ViewController.swift
//  APIClient-Example
//
//  Created by Roman Kyrylenko on 1/23/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import UIKit
import APIClient

class ViewController: UIViewController {
    
    @IBOutlet private var ipAddressTextField: UITextField!
    @IBOutlet private var dataTextView: UITextView!
    
    let geoServiceNetworkClient: NetworkClient = APIClient(
        requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.geoServiceBaseURL)
    )
    
    let ipServiceNetworkClient: NetworkClient = APIClient(
        requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.ipServiceBaseURL)
    )
    
    @IBAction private func findCurrentIP() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ipServiceNetworkClient.execute(
            request: IPAddressRequest(),
            parser: DecodableParser<IPAddress>()
        ) { [weak self] response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response {
            case .success(let result):
                self?.display(ipAddress: result)
                
            case .failure(let error):
                self?.display(error: error)
            }
        }
    }

    @IBAction private func findData() {
        geoServiceNetworkClient.execute(
            request: IPAddressDataRequest(ipAddress: ipAddressTextField.text ?? ""),
            parser: DecodableParser<LocationMetaData>(
        )) { [weak self] response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response {
            case .success(let result):
                self?.display(data: result)
                
            case .failure(let error):
                self?.display(error: error)
            }
        }
    }
    
    private func display(error: Error) {
        dataTextView.text = "\(error)"
    }
    
    private func display(ipAddress: IPAddress) {
        ipAddressTextField.text = ipAddress.ip
    }
    
    private func display(data: LocationMetaData) {
        dataTextView.text = "\(data)"
    }
}
