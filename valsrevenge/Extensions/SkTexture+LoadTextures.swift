//
//  SkTexture+LoadTextures.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//

import SpriteKit

extension SKTexture {
    static func loadTextures(atlas: String, prefix: String,
                             startsAt: Int, stopsAt: Int) -> [SKTexture] {
        
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startsAt...stopsAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        
        return textureArray
    }
}
