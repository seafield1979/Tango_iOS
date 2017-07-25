//
//  PageViewBackup.swift
//  TangoBook
//    単語帳作成ページ
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


public class PageViewTangoEdit : UPageView, UButtonCallbacks {
    
    /**
     * Constants
     */
    public static let TAG = "PageViewTitle"
    private static let DRAW_PRIORITY = 100
    
    internal static let MARGIN_H2 = 18
    internal static let MARGIN_V2 = 10
    
    private static let TEXT_SIZE = 17
    private static let IMAGE_W = 35
    
    // button Ids
    private static let buttonId1 = 100
    
    /**
     * Member variables
     */
    // Title
    private var mTitleText : UTextView? = nil
    
    // Buttons
    private var mButtons : [UButtonText] = []
    
    /**
     * Constructor
     */
    public override init(parentView : TopView, title : String) {
        super.init(parentView: parentView, title: title)
        
        
    }
    
    /**
     * Methods
     */
    
    override public func onShow() {
        
    }
    
    override public func onHide() {
        super.onHide()
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        let width = self.mTopView!.getWidth()
        
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()
        
        let button = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: PageViewTangoEdit.buttonId1, priority: PageViewTangoEdit.DRAW_PRIORITY,
            text: "test", x: 50, y: 100,
            width: width - 100, height: 100,
            textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        button.addToDrawManager()
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    override public func onBackKeyDown() -> Bool {
        return false
    }
    
    /**
     * Callbacks
     */
    
    /**
     * UButtonCallbacks
     */
    // ボタンがクリックされた時の処理
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        return false
    }
}

