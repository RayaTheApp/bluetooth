//
//  CharacteristicsViewController.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/19/16.
//  Copyright © 2016 Joshua Homann. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  var peripheral: CBPeripheral!
  var service: CBService!
  var lastValue: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    peripheral.delegate = self
    peripheral.discoverCharacteristics(nil, for: service)
  }
}

extension CharacteristicsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return service.characteristics?.count ?? 0
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    let characteristic = service.characteristics![indexPath.row]
    cell.textLabel?.text = "Characteristic: \(characteristic.uuid)"
    cell.detailTextLabel?.text = "Value: \(lastValue ?? "none")"
    return cell
  }

}

extension CharacteristicsViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristic = service.characteristics?.first else {
      return
    }
    peripheral.readValue(for: characteristic)
    self.service = service
    tableView.reloadData()
  }
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    lastValue = characteristic.value.flatMap{String(data: $0, encoding: .utf8)}
    tableView.reloadData()
  }
}


