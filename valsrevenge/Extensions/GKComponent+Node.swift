//
//  GKComponent+Node.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//
import SpriteKit
import GameplayKit

extension GKComponent {
    var componentNode: SKNode {
        if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {
            return node
        } else if let node = entity?.component(ofType:
                                                RenderComponent.self)?.spriteNode {
            return node
        }
        
        return SKNode()
    }
}
