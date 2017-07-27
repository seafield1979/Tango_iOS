//
//  UIcon.swift
//  TangoBook
//      他のアイコンを内包できるアイコン
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 抽象クラス  
 アイコンを内包する単語帳、ホーム、ゴミ箱等のクラスはこのクラスを継承する
 */
public class IconContainer : UIcon {
    /**
     * Constants
     */
    
    /**
     * Memver variable
     */
    var subWindow : UIconWindow? = nil
    
    /**
     * Get/Set
     */
    public func getSubWindow() -> UIconWindow? {
        return subWindow
    }
    
    // 自分が親になるとき(内包するアイコンがあるとき）の自分のParentTypeを返す
    public func getParentType() -> TangoParentType {
        // 抽象メソッド
        return TangoParentType.Home    // ダミー
    }
    
    /**
     * Initializer
     */
    public override init( parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?,
                 type : IconType,
                 x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat)
    {
        super.init(parentWindow: parentWindow, iconCallbacks: iconCallbacks,
                   type: type, x: x, y: y, width: width, height: height)
    }
}
