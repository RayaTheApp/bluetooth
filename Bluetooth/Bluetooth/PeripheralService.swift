//
//  PeripheralService.swift
//  Bluetooth
//
//  Created by Joshua Homann on 7/12/19.
//  Copyright © 2019 Raya. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class PeripheralService: NSObject {
  var peripheralManager: CBPeripheralManager! = nil
  static let shared = PeripheralService()
  static let serviceUuid = CBUUID(string: "7CDEDC98-4C07-4FB8-A46C-C91836380FE2")
  static let characteristicUuid = CBUUID(string: "463B26CB-4C6B-4AB9-B3EE-0E2C66C63759")
  static var characteristicValue: Data {
    return String("Custom on \(UIDevice.current.name)".prefix(20)).data(using: .utf8)!
  }
  private override init() {
    super.init()
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
}

extension PeripheralService: CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
      let characteristic = CBMutableCharacteristic(
        type: PeripheralService.characteristicUuid,
        properties: .read,
        value: PeripheralService.characteristicValue,
        permissions: .readable)
      let service = CBMutableService(type: PeripheralService.serviceUuid, primary: true)
      service.characteristics = [characteristic]
      peripheral.add(service)
      peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [PeripheralService.serviceUuid]])
    case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
      break
    @unknown default:
      break
    }
  }
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    request.value = PeripheralService.characteristicValue
    peripheral.respond(to: request, withResult: .success)
  }
}
