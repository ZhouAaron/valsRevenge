//
//  MonsterEntity.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
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
