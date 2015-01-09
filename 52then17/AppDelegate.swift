//
//  AppDelegate.swift
//  52then17
//
//  Created by Spencer Wood on 1/9/15.
//  Copyright (c) 2015 Spencer Wood. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var StatusMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let icon = "Break 5:32"
        statusItem.title = icon
        statusItem.menu = StatusMenu
    }

    @IBAction func pauseClicked(sender: NSMenuItem) {
    }

    @IBAction func workClicked(sender: NSMenuItem) {
    }
    
    @IBAction func breakClicked(sender: NSMenuItem) {
    }
}

