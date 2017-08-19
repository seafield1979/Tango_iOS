//
//  CGRect+U.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

// CGRect の origin.x origin.y size.width size.height に値を設定できるプロパティを追加
extension CGRect {
    // MARK: SpriteKit
    /**
     SpriteKit座標系のRectに変換する
     ※SpriteKitでは height がマイナスになると cornerRadiusが効かないので yの座標を調節する
     */
    public func convToSK() -> CGRect {
        return CGRect(x: self.x, y: -self.y - self.height,
                      width: self.width, height: self.height)
    }
}
