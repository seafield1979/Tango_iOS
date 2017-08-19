//
//  SKScene+ex.swift
//  SK_UGui
//
//  Created by Shusuke Unno on 2017/08/17.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

extension SKScene {
    
    public func getWidth() -> CGFloat {
        return size.width
    }
    
    public func getHeight() -> CGFloat {
        return size.height
    }
    
    /**
     追加するノードの座標系をUIView -> SpriteKitに変換してから
     シーンに追加する
     */
    public override func addChild2(_ node : SKNode) {
        node.position = self.convertPoint(fromView: node.position)
        self.addChild(node)
    }
}
