//
//  CentralService.swift
//  Bluetooth
//
//  Created by Joshua Homann on 7/12/19.
//  Copyright © 2019 Raya. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralService: NSObject {
    var centralManager: CBCentralManager! = nil
    static let shared = CentralService()
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension CentralService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }
}

