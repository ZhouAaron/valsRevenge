//
//  GeneratorComponent.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//

import SpriteKit
import GameplayKit

class GeneratorComponent: GKComponent {
    
    @GKInspectable var monsterType: String = GameObject.defaultGeneratorType
    @GKInspectable var maxMonsters: Int = 10
    
    @GKInspectable var waitTime: TimeInterval = 5
    @GKInspectable var monsterHealth: Int = 3
    
    var isRunning = false
    
    override func didAddToEntity() {
        let physicsComponent = PhysicsComponent()
        physicsComponent.bodyCategory = PhysicsCategory.monster.rawValue
        componentNode.entity?.addComponent(physicsComponent)
    }
    
    func startGenerator() {
        isRunning = true
        
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
    
    func stopGenerator() {
        isRunning = false
        componentNode.removeAction(forKey: "spawnMonster")
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
            
            // Initial spawn movement
            let randomPositions: [CGFloat] = [-50,-50,50]
            let randomX = randomPositions.randomElement() ?? 0
            monsterNode.run(SKAction.moveBy(x: randomX, y: 0, duration: 1.0))
            
            let healthComponent = HealthComponent()
            healthComponent.currentHealth = monsterHealth
            monsterEntity.addComponent(healthComponent)
            
            let agentComponent = AgentComponent()
            monsterEntity.addComponent(agentComponent)
            
            let physicsComponent = PhysicsComponent()
            physicsComponent.bodyCategory = PhysicsCategory.monster.rawValue
            monsterEntity.addComponent(physicsComponent)
            
            if let scene = componentNode.scene as? GameScene {
                scene.entities.append(monsterEntity)
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let scene = componentNode.scene as? GameScene {
            switch scene.mainGameStateMachine.currentState {
            case is PauseState:
                if isRunning == true {
                    stopGenerator()
                }
            case is PlayingState:
                if isRunning == false {
                    startGenerator()
                }
            default:
                break
            }
        }
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
