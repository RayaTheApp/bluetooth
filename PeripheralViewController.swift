//
//  PeripheralViewController.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/19/16.
//  Copyright © 2016 Ecoautomation. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {
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

extension PeripheralViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let service = services[services.index(services.startIndex, offsetBy: indexPath.row)]
        cell?.textLabel?.text = "Service: \(service.uuid)"
        return cell!
    }
}

extension PeripheralViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: String(describing: CharacteristicsViewController.self), sender: self)
    }
}

extension PeripheralViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            services.forEach { self.services.insert($0) }
            tableView.reloadData()
        }
    }
}
