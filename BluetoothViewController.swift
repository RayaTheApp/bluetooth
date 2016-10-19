//
//  AddBluetoothBridgeViewController.swift
//  Eco
//
//  Created by Joshua Homann on 10/18/16.
//  Copyright © 2016 Eco Automation. All rights reserved.
//

import UIKit
import CoreBluetooth

class AddBluetoothBridgeViewController: UIViewController {
    
    var peripherals = Set<CBPeripheral>()
    var connectedPeripheral: CBPeripheral!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectedPeripheral = nil
        barButtonItem.title = centralManager.isScanning ? "Stop" : "Start"
    }
    
    deinit {
        centralManager.stopScan()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PeripheralViewController {
            centralManager.stopScan()
            destination.peripheral = connectedPeripheral
        }
    }
    
    @IBAction func tapStartStop(_ sender: UIBarButtonItem) {
        if centralManager.isScanning {
            peripherals.removeAll()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            sender.title = "Stop"
        } else {
            centralManager.stopScan()
            sender.title = "Start"
        }
    }
    
    
    
}

extension AddBluetoothBridgeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let peripheral = peripherals[peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)]
        cell?.textLabel?.text = "Name: \(peripheral.name ?? "<none>")"
        cell?.detailTextLabel?.text = "Identifier: \(peripheral.identifier)"
        return cell!
    }
}

extension AddBluetoothBridgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)]
        centralManager.connect(peripheral, options: nil)
    }
}

extension AddBluetoothBridgeViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("\nBlue tooth supported. Scanning...")
        case .poweredOff, .unsupported, .unauthorized:
            print("Blue tooth not supported")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripherals.contains(peripheral) == false else {
            return
        }
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
        performSegue(withIdentifier: String(describing: PeripheralViewController.self), sender: self)
    }
    
}

extension AddBluetoothBridgeViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if (service.uuid == CBUUID(string: "EcobridgeSerivceUUID")) {
                    peripheral.discoverCharacteristics(nil, for: service)
                    centralManager.stopScan()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "Bridge characteristic") {
                let value: UInt8 = 0xDE
                let data = Data(bytes: [value])
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
}


