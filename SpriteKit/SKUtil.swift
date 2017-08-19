//
//  SKUtil.swift
//  SK_UGui
//    SpriteKit用の便利機能を提供するクラス
//  Created by Shusuke Unno on 2017/08/11.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class SKUtil {
    
    /**
     SpriteKitの座標系に変換する
     変換が必要なのは y軸のみ
     */
    public static func convY(fromView y: CGFloat) -> CGFloat {
        return -y
    }
    
}
