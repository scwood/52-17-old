//
//  AppDelegate.swift
//  52then17
//
//  Created by Spencer Wood on 1/9/15.
//  Copyright (c) 2015 Spencer Wood. All rights reserved.
//

//
// To do:
// - Refactor timer into seperate class
// - Switch mode logic to enumeration and switches where appropriate
// - Change open book icon
// - Pomodoro mode
// - Custom mode
// - About menu item
// - Distribute on github
// - Auto updates?

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  // Mode enumeration
  enum Mode {
    case None
    case Work
    case Break
  }

  // Constants
  let notifications = NSUserNotificationCenter.defaultUserNotificationCenter()
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
  let openIcon = NSImage(named: "openIcon")
  let closedIcon = NSImage(named: "closedIcon")
  let workMinutes = 52.0
  let breakMinutes = 17.0
  let pomodoroWorkMinutes = 25.0
  let pomodoroShortBreakMinutes = 5.0
  let pomodoroLongBreakMinutes = 15.0
  let timerLagOffset = 3.0

  // Variables
  var currentMode = Mode.None
  var paused = false
  var remainingMinutes = Int()
  var remainingSeconds = Int()
  var secondsString = String()
  var alarm = NSTimer()
  var timer = NSTimer()
  var currentTime = NSDate()
  var endingTime = NSDate()
  var timeDifference = Int()
  var pomodoroCount = Int()
  var customWorkMinutes = Double()
  var customBreakMinutes = Double()

  // Menu and window outlets
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var timerLabel: NSMenuItem!
  @IBOutlet weak var pauseLabel: NSMenuItem!
  @IBOutlet weak var changeIntervalMenu: NSMenu!
  
  // Run at application launch
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    statusItem.button?.image = closedIcon
    statusItem.button?.appearsDisabled = true
    closedIcon?.setTemplate(true)
    openIcon?.setTemplate(true)
    statusItem.menu = statusMenu
  }

  // Helper functions ---------------------------------------------------------

  func startSession(mode: Mode) -> Void {
    currentMode = mode
    paused = false
    pauseLabel.title = "Pause Timer"
    updateIcon()
    currentTime = NSDate()
    if currentMode == .Work {
      remainingMinutes = Int(workMinutes)
      endingTime = currentTime.dateByAddingTimeInterval(
        60 * workMinutes + timerLagOffset)
      startAlarm(workMinutes, seconds: timerLagOffset)
    } else if currentMode == .Break {
      remainingMinutes = Int(breakMinutes)
      endingTime = currentTime.dateByAddingTimeInterval(
        60 * breakMinutes + timerLagOffset)
      startAlarm(breakMinutes, seconds: timerLagOffset)
    }
    startTimer()
    showNotification()
  }
  
  func endSession() -> Void {
    if currentMode == .Work {
      startSession(.Break)
    } else if currentMode == .Break {
      startSession(.Work)
    }
  }

  func startAlarm(minutesConstant: Double, seconds: Double) -> Void {
    alarm.invalidate()
    alarm = NSTimer(
      timeInterval: 60 * minutesConstant + seconds,
      target:self,
      selector: Selector("endSession"),
      userInfo: nil,
      repeats:false)
    NSRunLoop.mainRunLoop().addTimer(alarm, forMode: NSRunLoopCommonModes)
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
    if timeDifference > 0 {
      remainingMinutes = timeDifference / 60
      remainingSeconds = timeDifference % 60
      if remainingSeconds == 0 {
        remainingSeconds = 59;
        remainingMinutes--
      } else {
        remainingSeconds--
      }
      secondsString = String(format: "%02d", remainingSeconds)
      if currentMode == .Work && !paused {
        timerLabel.title =
          "Work: \(remainingMinutes):\(secondsString) Remaining"
      } else if currentMode == .Break && !paused {
        timerLabel.title =
          "Break: \(remainingMinutes):\(secondsString) Remaining"
      } else if currentMode == .Work && paused {
        timerLabel.title =
          "Work: \(remainingMinutes):\(secondsString) (Paused)"
      } else if currentMode == .Break && paused {
        timerLabel.title =
          "Break: \(remainingMinutes):\(secondsString) (Paused)"
      }
    }
  }
  
  func showNotification() -> Void {
    var alarmNotification = NSUserNotification()
    alarmNotification.title = "52then17"
    if currentMode == .Work {
      alarmNotification.informativeText = "Work session started."
    } else if currentMode == .Break {
      alarmNotification.informativeText = "Break started."
    }
    alarmNotification.soundName = NSUserNotificationDefaultSoundName
    notifications.deliverNotification(alarmNotification)
  }
  
  func updateIcon() -> Void {
    if currentMode == .None || (currentMode == .Break && paused) {
      statusItem.button?.image = closedIcon
      statusItem.button?.appearsDisabled = true
    } else if currentMode == .Work && !paused {
      statusItem.button?.image = openIcon
      statusItem.button?.appearsDisabled = false
    } else if currentMode == .Work && paused {
      statusItem.button?.image = openIcon
      statusItem.button?.appearsDisabled = true
    } else if currentMode == .Break && !paused {
      statusItem.button?.image = closedIcon
      statusItem.button?.appearsDisabled = false
    }
  }

  // Menu buttons -------------------------------------------------------------

  @IBAction func workClicked(sender: NSMenuItem) {
    startSession(.Work)
  }

  @IBAction func breakClicked(sender: NSMenuItem) {
    startSession(.Break)
  }

  @IBAction func pauseClicked(sender: NSMenuItem) {
    if !paused && currentMode != .None {
      timer.invalidate()
      alarm.invalidate()
      paused = true
      updateIcon()
      updateTimerLabel()
      pauseLabel.title = "Resume Timer"
    } else if paused {
      currentTime = NSDate()
      endingTime = currentTime.dateByAddingTimeInterval(
        (60 * Double(remainingMinutes)) +
        Double(remainingSeconds) + timerLagOffset)
      startTimer()
      startAlarm(
        Double(remainingMinutes),
        seconds: Double(remainingSeconds) + timerLagOffset)
      paused = false
      updateIcon()
      pauseLabel.title = "Pause Timer"
    }
  }

  @IBAction func stopClicked(sender: NSMenuItem) {
    alarm.invalidate()
    timer.invalidate()
    timerLabel.title = "No Timer Started"
    currentMode = .None
    paused = false
    updateIcon()
  }

  @IBAction func quitClicked(sender: NSMenuItem) {
    alarm.invalidate()
    timer.invalidate()
    exit(0)
  }
}
