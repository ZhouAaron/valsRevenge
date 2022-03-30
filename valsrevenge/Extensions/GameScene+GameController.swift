//
//  GameScene+GameController.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import GameController

extension GameScene {
  
  // Add observers to track connecting and disconnecting external controllers
  func observeForGameControllers() {
    NotificationCenter.default.addObserver(self, selector: #selector(connectControllers),
                                           name: NSNotification.Name.GCControllerDidConnect,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers),
                                           name: NSNotification.Name.GCControllerDidDisconnect,
                                           object: nil)
  }
  
  // This method gets called when a new controller is connected
  @objc func connectControllers() {
    self.isPaused = false
    var indexNumber = 0
    
    for controller in GCController.controllers() {
      guard let _ = controller.extendedGamepad else {
        return
      }
      
      controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
      indexNumber += 1
      setupControllerControls(controller: controller)
    }
  }
  
  // This method gets called when a controller is disconnected
  @objc func disconnectControllers() {
    self.isPaused = true // required by Apple
  }
  
  func setupControllerControls(controller: GCController) {
    controller.extendedGamepad?.valueChangedHandler = {
      (gamepad: GCExtendedGamepad, element: GCControllerElement) in
      self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
    }
  }
  
  func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
    
    // Range: -1...1 | < 0 = Left | > 0 = Right < 0 = Down | > 0 = Up
    
    if (gamepad.leftThumbstick == element) {
      let multiplier = Float(controllerMovement?.getRange() ?? 0.0)
      
      let xAxis = CGFloat(gamepad.leftThumbstick.xAxis.value * multiplier)
      let yAxis = CGFloat(gamepad.leftThumbstick.yAxis.value * multiplier)
      
      let location = CGPoint(x: xAxis, y: yAxis)
      controllerMovement?.moveJoystick(pos: location)
    }
    
    if (gamepad.rightThumbstick == element) {
      let multiplier = Float(controllerAttack?.getRange() ?? 0.0)
      
      let xAxis = CGFloat(gamepad.rightThumbstick.xAxis.value * multiplier)
      let yAxis = CGFloat(gamepad.rightThumbstick.yAxis.value * multiplier)
      
      let location = CGPoint(x: xAxis, y: yAxis)
      controllerAttack?.moveJoystick(pos: location)
    }
  }
}
