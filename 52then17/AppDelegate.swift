//
//  AppDelegate.swift
//  52then17
//
//  Created by Spencer Wood on 1/9/15.
//  Copyright (c) 2015 Spencer Wood. All rights reserved.
//

import Cocoa
import Darwin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let workMinutes = 52
    let breakMinutes = 17
    
    var minutes = 0
    var seconds = 0
    var secondsString = "00"
    var mode = "none"
    var paused = false
    var timer = NSTimer()
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timerLabel: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.title = "GTD"
        statusItem.menu = statusMenu
    }
    
    func startTimer(modeTemp: String) -> Void {
        mode = modeTemp
        paused = false
        if mode == "work" {
            minutes = workMinutes
        } else if mode == "break" {
            minutes = breakMinutes
        }
        seconds = 0
        secondsString = "00"
        updateLabel()
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
        showNotification()
    }
    
    func update() -> Void {
        if seconds == 0 && minutes == 0 {
            if mode == "work" {
                startTimer("break")
            } else if mode == "break" {
                startTimer("work")
            }
        } else {
            if seconds == 0 {
                seconds = 59;
                secondsString = String(seconds)
                minutes--
            } else if seconds <= 10 {
                seconds--
                secondsString = "0" + String(seconds)
            } else {
                seconds--
                secondsString = String(seconds)
            }
            updateLabel()
        }
    }
    
    func updateLabel() -> Void {
        if mode == "work" && !paused {
            timerLabel.title = "Working: " + String(minutes) + ":" + secondsString + " Remaining"
        } else if mode == "break" && !paused {
            timerLabel.title = "Break: " + String(minutes) + ":" + secondsString + " Remaining"
        } else if mode == "work" && paused {
            timerLabel.title = "Working (paused): " + String(minutes) + ":" + secondsString + " Remaining"
        } else if mode == "break" && paused {
            timerLabel.title = "Break (paused): " + String(minutes) + ":" + secondsString + " Remaining"
        }
    }
    
    func showNotification() -> Void {
        var notification = NSUserNotification()
        notification.title = "52then17"
        if mode == "work" {
            notification.informativeText = "Work session started."
        } else if mode == "break" {
            notification.informativeText = "Break started."
        }
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    @IBAction func workClicked(sender: NSMenuItem) {
        startTimer("work")
    }
    
    @IBAction func breakClicked(sender: NSMenuItem) {
        startTimer("break")
    }
    
    @IBAction func pauseClicked(sender: NSMenuItem) {
        if !paused && mode != "none" {
            timer.invalidate()
            paused = true
            updateLabel()
        } else if paused {
            paused = false
            updateLabel()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("update"), userInfo: nil, repeats:true)
        }
    }
    @IBAction func stopClicked(sender: NSMenuItem) {
        timer.invalidate()
        mode = "none"
        paused = false
        timerLabel.title = "No Timer Started"
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        exit(0)
    }
}