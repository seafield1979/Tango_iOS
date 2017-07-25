//
//  TangoTopView.swift
//  TangoBook
//    単語アプリのトップView
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

class TangoTopView : TopView {
    // Consts
    
    // Propaties
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        // ページマネージャーを初期化
        self.mPageManager = PageViewManagerMain.createInstance(topView: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     描画処理
     - parameter rect: 再描画領域の矩形
     - throws: none
     - returns: none
     */
//    override public func draw(_ rect: CGRect) {
//        // 現在のページの描画
//        if (mPageManager!.draw()) {
//            redraw = true
//        }
//        
//        // マネージャに登録した描画オブジェクトをまとめて描画
//        if UDrawManager.getInstance().draw() == true {
//            redraw = true
//        }
//    }
}

