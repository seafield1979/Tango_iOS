//
//  SKUNode.swift
//  SK_UGui
//      UDrawableに保持されるノード
//  Created by Shusuke Unno on 2017/08/10.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit
import GameplayKit

// UDrawableと関連づけられるノード
class SKUNode: SKNode {
    
    public var mDrawable : UDrawable? = nil
    // 移動速度
    public var movingSpeed : CGPoint = CGPoint()
    
    // 移動端
    public var minPos = CGPoint()
    public var maxPos = CGPoint()
    
    init( drawable : UDrawable ) {
        super.init()
        
        mDrawable = drawable
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 移動する
    public func move() {
        self.position.x += movingSpeed.x
        self.position.y += movingSpeed.y
        
        let hw = self.frame.size.width / 2
        let hh = self.frame.size.height / 2
        if self.position.x - hw < minPos.x {
            position.x = minPos.x + hw
            movingSpeed.x *= -1
        }
        if self.position.y - hh < minPos.y {
            position.y = minPos.y + hh
            movingSpeed.y *= -1
        }
        if self.position.x + hw > maxPos.x {
            position.x = maxPos.x - hw
            movingSpeed.x *= -1
        }
        if self.position.y + hh > maxPos.y {
            position.y = maxPos.y - hh
            movingSpeed.y *= -1
        }
    }
}
