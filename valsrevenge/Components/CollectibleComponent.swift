//
//  CollectibleComponent.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//

import SpriteKit
import GameplayKit

struct Collectible {
    let type: GameObjectType
    
    let collectSoundFile: String
    let destroySoundFile: String
    
    let canDestroy: Bool
    
    init(type: GameObjectType, collectSound: String,
         destroySound: String, canDestroy: Bool = false) {
        self.type = type
        
        self.collectSoundFile = collectSound
        self.destroySoundFile = destroySound
        
        self.canDestroy = canDestroy
    }
}

// MARK: - COMPONENT CODE STARTS HERE

class CollectibleComponent: GKComponent {
    // meaning you’ll have access to them in the Scene Editor.
    @GKInspectable var collectibleType: String =
    GameObject.defaultCollectibleType
    @GKInspectable var value: Int = 1
    
    private var collectSoundAction = SKAction()
    private var destroySoundAction = SKAction()
    private var canDestroy = false
    
    override func didAddToEntity() {
        guard let collectible =
                GameObject.forCollectibleType(GameObjectType(rawValue: collectibleType))
        else {
            return
        }
        // preload these action so that there is no delay when you first play the sound
        collectSoundAction =
        SKAction.playSoundFileNamed(collectible.collectSoundFile,
                                    waitForCompletion: false)
        
        destroySoundAction =
        SKAction.playSoundFileNamed(collectible.destroySoundFile,
                                    waitForCompletion: false)
        
        canDestroy = collectible.canDestroy
    }
    
    func collectedItem() {
        componentNode.run(collectSoundAction, completion: {
            self.componentNode.removeFromParent()
        })
    }
    
    func destroyedItem() {
        if canDestroy == true {
            componentNode.run(destroySoundAction, completion: {
                self.componentNode.removeFromParent()
            })
        }
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
