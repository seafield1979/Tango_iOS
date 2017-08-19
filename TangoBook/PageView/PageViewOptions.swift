//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewOptions : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    // モード(リストに表示する項目が変わる)
    public enum Mode {
        case All        // 全オプションを表示
        case Edit       // 単語帳編集系の項目を表示
        case Study       // 学習系の項目を表示
    }
    /**
     * Constants
     */
    public static let TAG = "PageViewOptions"
    
    // button id
    private static let buttonId1 = 100
    
    private static let DRAW_PRIORITY = 100
    
    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public override init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, title: title)
    }
    
    /**
     * Methods
     */
    
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    override public func initDrawables() {
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()
        
        // ここにページで表示するオブジェクト生成処理を記述
        let width = self.mTopScene.getWidth()
        
        let button = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: PageViewOptions.buttonId1, priority: PageViewOptions.DRAW_PRIORITY,
            text: "test", x: 50, y: 100,
            width: width - 100, height: 100,
            textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        button.addToDrawManager()
        
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool
    {
        return true
    }
}

