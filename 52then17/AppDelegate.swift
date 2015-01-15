//
//  AppDelegate.swift
//  52then17
//
//  Created by Spencer Wood on 1/9/15.
//  Copyright (c) 2015 Spencer Wood. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  // Constants
  let notifications = NSUserNotificationCenter.defaultUserNotificationCenter()
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
  let workMinutes = 52.0
  let breakMinutes = 17.0

  // Variables
  var mode = "none"
  var paused = false
  var remainingMinutes = Int()
  var remainingSeconds = Int()
  var secondsString = String()
  var alarm = NSTimer()
  var timer = NSTimer()
  var currentTime = NSDate()
  var endingTime = NSDate()
  var timeDifference = Int()

  // Menu and window outlets
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var timerLabel: NSMenuItem!
  
  // Run at application launch
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    statusItem.title = "GTD"
    statusItem.menu = statusMenu
  }

  // Helper functions ---------------------------------------------------------

  func startSession(modeTemp: String) -> Void {
    mode = modeTemp
    paused = false
    currentTime = NSDate()
    if mode == "work" {
      remainingMinutes = Int(workMinutes)
      endingTime = currentTime.dateByAddingTimeInterval(60 * workMinutes)
      startAlarm(workMinutes)
    } else if mode == "break" {
      remainingMinutes = Int(breakMinutes)
      endingTime = currentTime.dateByAddingTimeInterval(60 * breakMinutes)
      startAlarm(breakMinutes)
    }
    showNotification()
    startTimer()
  }
  
  func endSession() -> Void {
    if mode == "work" {
      mode == "break"
      startSession("break")
    } else {
      mode == "work"
      startSession("work")
    }
  }

  func startAlarm(minutesConstant: Double) -> Void {
    alarm.invalidate()
    alarm = NSTimer.scheduledTimerWithTimeInterval(
      60 * minutesConstant,
      target:self,
      selector: Selector("endSession"),
      userInfo: nil,
      repeats:false)
  }

  func startTimer() -> Void {
    timer.invalidate()
    timer = NSTimer(
      timeInterval:1,
      target:self,
      selector: Selector("updateTimerLabel"),
      userInfo: nil,
      repeats:true)
    NSRunLoop.currentRunLoop().addTimer(timer, forMode:NSRunLoopCommonModes)
  }

  func updateTimerLabel() -> Void {
    currentTime = NSDate()
    timeDifference = Int(endingTime.timeIntervalSinceDate(currentTime))
    remainingMinutes = timeDifference / 60
    remainingSeconds = timeDifference % 60
    if remainingSeconds == 0 {
      remainingSeconds = 59;
      remainingMinutes--
    } else {
      remainingSeconds--
    }
    secondsString = String(format: "%02d", remainingSeconds)
    if mode == "work" && !paused {
      timerLabel.title =
        "Work: \(remainingMinutes):\(secondsString) Remaining"
    } else if mode == "break" && !paused {
      timerLabel.title =
        "Break: \(remainingMinutes):\(secondsString) Remaining"
    } else if mode == "work" && paused {
      timerLabel.title =
        "Work (paused): \(remainingMinutes):\(secondsString) Remaining"
    } else if mode == "break" && paused {
      timerLabel.title =
        "Break (paused): \(remainingMinutes):\(secondsString) Remaining"
    }
  }
  
  func showNotification() -> Void {
    var alarmNotification = NSUserNotification()
    alarmNotification.title = "52then17"
    if mode == "work" {
      alarmNotification.informativeText = "Work session started."
    } else if mode == "break" {
      alarmNotification.informativeText = "Break started."
    }
    alarmNotification.soundName = NSUserNotificationDefaultSoundName
    notifications.deliverNotification(alarmNotification)
  }
  
  // Work in progress
  func updateIcon() -> Void {
    if mode == "none" {
    } else if mode == "work" && !paused {
    } else if mode == "work" && paused {
    } else if mode == "break" && !paused {
    } else if mode == "break" && paused {
    }
  }

  // Menu buttons -------------------------------------------------------------

  @IBAction func workClicked(sender: NSMenuItem) {
    startSession("work")
  }

  @IBAction func breakClicked(sender: NSMenuItem) {
    startSession("break")
  }

  @IBAction func pauseClicked(sender: NSMenuItem) {
    if !paused && mode != "none" {
      timer.invalidate()
      paused = true
      updateTimerLabel()
    } else if paused {
      paused = false
      updateTimerLabel()
      startTimer()
    }
  }

  @IBAction func stopClicked(sender: NSMenuItem) {
    alarm.invalidate()
    timer.invalidate()
    mode = "none"
    paused = false
    timerLabel.title = "No Timer Started"
  }

  @IBAction func quitClicked(sender: NSMenuItem) {
    alarm.invalidate()
    timer.invalidate()
    exit(0)
  }
}
