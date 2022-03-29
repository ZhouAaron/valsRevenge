//
//  MonsterEntity.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//

import SpriteKit
import GameplayKit

class MonsterEntity: GKEntity {
  
  init(monsterType: String) {
    super.init()
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder:coder)
  }
}
