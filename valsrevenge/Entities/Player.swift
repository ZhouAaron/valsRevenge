//
//  Player.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import SpriteKit

enum Direction: String {
  case stop
  case left
  case right
  case up
  case down
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
}

class Player: SKSpriteNode {
  
  private var currentDirection = Direction.stop
  
  func move(_ direction: Direction) {
    print("move player: \(direction.rawValue)")
    switch direction {
    case .up:
      self.physicsBody?.velocity = CGVector(dx: 0, dy: 100)
      //self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
    //self.physicsBody?.applyForce(CGVector(dx: 0, dy: 100))
    case .down:
      self.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
    case .left:
      self.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
    case .right:
      self.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
    case .topLeft:
      self.physicsBody?.velocity = CGVector(dx: -100, dy: 100)
    case .topRight:
      self.physicsBody?.velocity = CGVector(dx: 100, dy: 100)
    case .bottomLeft:
      self.physicsBody?.velocity = CGVector(dx: -100, dy: -100)
    case .bottomRight:
      self.physicsBody?.velocity = CGVector(dx: 100, dy: -100)
    case .stop:
      stop()
    }
    
    if direction != .stop {
      currentDirection = direction
    }
  }
  
  func stop() {
    self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
  }
  
  func attack() {
    let projectile = SKSpriteNode(imageNamed: "knife")
    projectile.position = CGPoint(x: 0.0, y: 0.0)
    addChild(projectile)
    
    var throwDirection = CGVector(dx: 0, dy: 0)
    
    switch currentDirection {
    case .up:
      throwDirection = CGVector(dx: 0, dy: 300)
      projectile.zRotation = 0
    case .down:
      throwDirection = CGVector(dx: 0, dy: -300)
      projectile.zRotation = -CGFloat.pi
    case .left:
      throwDirection = CGVector(dx: -300, dy: 0)
      projectile.zRotation = CGFloat.pi/2
    case .right, .stop: // default pre-movement (throw right)
      throwDirection = CGVector(dx: 300, dy: 0)
      projectile.zRotation = -CGFloat.pi/2
    case .topLeft:
      throwDirection = CGVector(dx: -300, dy: 300)
      projectile.zRotation = CGFloat.pi/4
    case .topRight:
      throwDirection = CGVector(dx: 300, dy: 300)
      projectile.zRotation = -CGFloat.pi/4
    case .bottomLeft:
      throwDirection = CGVector(dx: -300, dy: -300)
      projectile.zRotation = 3 * CGFloat.pi/4
    case .bottomRight:
      throwDirection = CGVector(dx: 300, dy: -300)
      projectile.zRotation = 3 * -CGFloat.pi/4
    }
    
    let throwProjectile = SKAction.move(by: throwDirection, duration: 0.25)
    projectile.run(throwProjectile,
                   completion: {projectile.removeFromParent()})
  }
}
