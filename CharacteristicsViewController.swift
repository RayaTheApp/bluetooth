//
//  CharacteristicsViewController.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/19/16.
//  Copyright © 2016 Ecoautomation. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var peripheral: CBPeripheral!
    var service: CBService!
    
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let characteristic = service.characteristics![indexPath.row]
        cell?.textLabel?.text = "Characteristic: \(characteristic.uuid)"
        cell?.detailTextLabel?.text = "\(characteristic.properties)"
        return cell!
    }
    
}

extension CharacteristicsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characteristic = service.characteristics![indexPath.row]
        let alert = UIAlertController(title: "Characteristic: \(characteristic.uuid)", message: "\(characteristic)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension CharacteristicsViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard service.characteristics?.count ?? 0 > 0 else {
            return
        }
        self.service = service
        tableView.reloadData()
    }
}


