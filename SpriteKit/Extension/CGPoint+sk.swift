//
//  CGPoint+ex.swift
//  SK_UGui
//      CGPointの拡張
//  Created by Shusuke Unno on 2017/08/13.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

extension CGPoint {
    
    /**
     UIKitの座標系からSpriteKitの座標系に変換する
     */
    public func convToSK() -> CGPoint {
        return CGPoint( x: self.x, y: -self.y)
    }
    
    public mutating func toSK() {
        self.y = -y
    }
    
    /**
     UIKitの座標系からSpriteKitの座標系に変換する
     Sceneにappendする際の変換
     */
    public mutating func toSK(fromView scene: SKScene) {
        self = scene.convertPoint(fromView: self)
    }
}
