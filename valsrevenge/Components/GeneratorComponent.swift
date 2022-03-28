//
//  GeneratorComponent.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GeneratorComponent: GKComponent {
  
  @GKInspectable var monsterType: String = GameObject.defaultGeneratorType
  @GKInspectable var maxMonsters: Int = 10
  
  @GKInspectable var waitTime: TimeInterval = 5
  @GKInspectable var monsterHealth: Int = 3
  
  override func didAddToEntity() {
    let wait = SKAction.wait(forDuration: waitTime)
    let spawn = SKAction.run { [unowned self] in self.spawnMonsterEntity() }
    let sequence = SKAction.sequence([wait, spawn])
    
    let repeatAction: SKAction?
    if maxMonsters == 0 {
      repeatAction = SKAction.repeatForever(sequence)
    } else {
      repeatAction = SKAction.repeat(sequence, count: maxMonsters)
    }
    
    componentNode.run(repeatAction!, withKey: "spawnMonster")
  }
  
  func spawnMonsterEntity() {
    let monsterEntity = MonsterEntity(monsterType: monsterType)
    let renderComponent = RenderComponent(imageNamed: "\(monsterType)_0",
      scale: 0.65)
    monsterEntity.addComponent(renderComponent)
    
    if let monsterNode =
      monsterEntity.component(ofType: RenderComponent.self)?.spriteNode {
      monsterNode.position = componentNode.position
      componentNode.parent?.addChild(monsterNode)
      
      monsterNode.run(SKAction.moveBy(x: 100, y: 0, duration: 1.0))
      
      let healthComponent = HealthComponent()
      healthComponent.currentHealth = monsterHealth
      monsterEntity.addComponent(healthComponent)
    }
  }
  
  override class var supportsSecureCoding: Bool {
    true
  }
}
