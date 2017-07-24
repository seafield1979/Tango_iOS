//
//  UCircle.swift
//  UGui
//  UDrawableを継承した円を描画するクラス
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

class UCircle : UDrawable {
    
    var radius : CGFloat = 10.0
    
    /**
     * 描画処理
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    override func draw(_ offset : CGPoint) {
        // 抽象クラス(Swiftではサポートされていないので仕方なく実装)
        UDraw.drawCircleFill(x: pos.x, y: pos.y, radius: radius, color: color!)
    }
}
