//
//  AppDelegate.swift
//  bluetooth
//
//  Created by Joshua Homann on 10/19/16.
//  Copyright © 2016 Joshua Homann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func applicationDidFinishLaunching(_ application: UIApplication) {
    _ = PeripheralService.shared
  }

}

