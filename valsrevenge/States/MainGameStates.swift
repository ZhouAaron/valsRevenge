//
//  MainGameStates.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//

import GameplayKit

class PauseState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self
    }
}

class PlayingState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PauseState.self
    }
}
