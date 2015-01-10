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
    
    var seconds = 59
    var workMins = 52
    var breakMins = 17
    var secondsString = "00"
    var timer = NSTimer()
    var paused = false
    var status = "none"

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let title = String(workMins) + ":" + String(seconds)
        statusItem.title = "GTD"
        statusItem.menu = statusMenu
    }
    
    @IBAction func pauseClicked(sender: NSMenuItem) {
        if !paused  {
            if status != "none" {
                statusItem.title = "GTD (paused)"
                timer.invalidate()
                paused = true
            }
        }
        else {
            paused = false
            if status != "none" {
                if status == "break" {
                    statusItem.title = "Break" + String(breakMins) + ":" + String (seconds)
                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
                }
                else if status == "work" {
                    statusItem.title = "Work" + String(workMins) + ":" + String (seconds)
                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
                }
            }
            else {
                startWork()
            }
        }
        timer.invalidate()
    }

    @IBAction func workClicked(sender: NSMenuItem) {
        startWork()
    }
    
    @IBAction func breakClicked(sender: NSMenuItem) {
        startBreak()
    }
    
    func update() {
        if status == "work" {
            if workMins == 0 && seconds == 0 {
                startBreak()
            }
        }
        else if status == "break" {
        }
    }
    
    func startWork() {
        status = "work"
        paused = false
        secondsString = "00"
        workMins = 52
        statusItem.title = String(workMins) + secondsString
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
    }
    
    func startBreak() {
        status = "break"
        paused = false
        secondsString = "00"
        breakMins = 17
        statusItem.title = String(breakMins) + secondsString
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
    }
}

