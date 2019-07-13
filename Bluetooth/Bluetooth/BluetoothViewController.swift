//
//  AddBluetoothBridgeViewController.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/18/16.
//  Copyright © 2016 Joshua Homann. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {
  @IBOutlet private var startStopButton: UIButton!
  @IBOutlet private var tableView: UITableView!
  
  private var centralManager: CBCentralManager!
  private var peripherals = Set<CBPeripheral>()
  private var localNames = [UUID : String]()
  private var connectedPeripheral: CBPeripheral!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: .main)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    connectedPeripheral = nil
    startStopButton.setTitle(centralManager.isScanning ? "Stop" : "Start", for: .normal)
  }
  
  deinit {
    centralManager.stopScan()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? ServiceViewController {
      centralManager.stopScan()
      destination.peripheral = connectedPeripheral
    }
  }
  
  @IBAction func tapStartStop(_ sender: UIButton) {
    if centralManager.isScanning {
      peripherals.removeAll()
      centralManager.scanForPeripherals(withServices: [PeripheralService.serviceUuid], options: nil)
    } else {
      centralManager.stopScan()
    }
    startStopButton.setTitle(centralManager.isScanning ? "Stop" : "Start", for: .normal)
  }
}

extension PeripheralViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripherals.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    }
    let peripheral = peripherals[peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)]
    cell?.textLabel?.text = "Name: \(peripheral.name ?? "No name")"
    cell?.detailTextLabel?.text = "Identifier: \(peripheral.identifier)"
    return cell!
  }
}

extension PeripheralViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let peripheral = peripherals[peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)]
    centralManager.connect(peripheral, options: nil)
  }
}

extension PeripheralViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      centralManager.scanForPeripherals(withServices: [PeripheralService.serviceUuid], options: nil)
      print("\nBlue tooth supported. Scanning...")
    case .poweredOff, .unsupported, .unauthorized:
      print("Blue tooth not supported")
    default:
      break
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print(advertisementData)
    peripherals.remove(peripheral)
    peripherals.insert(peripheral)
    tableView.reloadData()
    
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    let alert = UIAlertController(title: "error", message: "cannnot connected to \(peripheral)", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    guard connectedPeripheral == nil else {
      return
    }
    print("connected to \(peripheral)")
    connectedPeripheral = peripheral
    performSegue(withIdentifier: String(describing: ServiceViewController.self), sender: self)
  }
  
}
