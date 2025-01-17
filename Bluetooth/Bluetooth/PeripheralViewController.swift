//
//  PeripheralViewController.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/19/16.
//  Copyright © 2016 Joshua Homann. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  var peripheral: CBPeripheral!
  var services = Set<CBService>()
  override func viewDidLoad() {
    super.viewDidLoad()
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? CharacteristicsViewController, let indexPath = tableView.indexPathForSelectedRow {
      let service = services[services.index(services.startIndex, offsetBy: indexPath.row)]
      destination.service = service
      destination.peripheral = peripheral
    }
  }
  
}

extension ServiceViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return services.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    let service = services[services.index(services.startIndex, offsetBy: indexPath.row)]
    cell.textLabel?.text = "Service: \(service.uuid)"
    return cell
  }
}

extension ServiceViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: String(describing: CharacteristicsViewController.self), sender: self)
  }
}

extension ServiceViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    peripheral.services?.forEach { self.services.insert($0) }
    tableView.reloadData()
  }
}
