//
//  SKNode+ex.swift
//  SK_UGui
//
//  Created by Shusuke Unno on 2017/08/17.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

extension SKNode {
    /**
     * 座標系をSpriteKitのものに変換してから子ノードを追加
     */
    public func addChild2(_ node : SKNode) {
        node.position.toSK()
        self.addChild( node )
    }
}

extension SKSpriteNode {
    /**
     * UIKitの座標をSpriteKitの座標に変換する
     * SKNodeを親を持つノード限定
     */
    public func convPoint()  {
        self.position = CGPoint( x: self.position.x, y: -(self.position.y + self.size.height))
    }
    
    }

extension SKShapeNode {
    /**
     * UIKitの座標をSpriteKitの座標に変換する
     * SKNodeを親を持つノード限定
     */
    public func convPoint()  {
        self.position = CGPoint( x: self.position.x, y: -(self.position.y + self.frame.size.height))
    }
}

extension SKLabelNode {
    /**
     * UIKitの座標をSpriteKitの座標に変換する
     * SKNodeを親を持つノード限定
     */
    public func convPoint()  {
        self.position = CGPoint( x: self.position.x, y: -(self.position.y + self.frame.size.height))
    }
}
