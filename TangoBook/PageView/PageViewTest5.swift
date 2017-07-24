//
//  PageViewTest5.swift
//  UGui
//    リストビューのサンプル
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest5 : UPageView, UListItemCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest5"
    
    var listView : UListView? = nil
    var logWindow : ULogWindow? = nil
    
    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public override init( topView : TopView, title : String) {
        super.init( topView: topView, title: title)
        
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
        UDrawManager.getInstance().initialize()
        
        listView = UListView(
            parentView : mTopView!,
            windowCallbacks : nil,
            listItemCallbacks : self,
            priority : 100,
            x : 50.0, y : 50.0,
            width : 300, height : 400, color : UIColor.red)
  
        // アイテムを追加
        for _ in 0...19 {
            let item = ListItemTest1(callbacks: self,
                                     text: "hoge",
                                     x: 0, width: listView!.size.width,
                                     color:UIColor.yellow)
            listView?.add(item: item)
        }
        listView?.updateWindow()
        
        listView?.addToDrawManager()
        
        // ULogWindow
        // 自動で描画リストに追加される
        logWindow = ULogWindow.createInstance(
            parentView: mTopView!, type: LogWindowType.Fix,
            x: 0, y: CGFloat(UUtil.screenHeight()) - 450.0,
            width: CGFloat(UUtil.screenWidth()),
            height: CGFloat(UUtil.screenHeight()) / 2 - UUtil.navigationBarHeight())
    }
    
    // ダイアログを表示する
    func showDialog() {
        let dialog = UPopupWindow(parentView: mTopView!,
                                  popupType: UPopupType.OKCancel,
                                  title: "hoge", isAnimation: true,
                                  screenW: CGFloat(UUtil.screenWidth()),
                                  screenH: CGFloat(UUtil.screenHeight()))
        dialog.addToDrawManager()
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
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked(item : UListItem) {
        logWindow!.addLog("item : " + item.getIndex().description)
    }
    
    /**
     * 項目のボタンがクリックされた
     */
    public func ListItemButtonClicked(item : UListItem, buttonId : Int) {
        
    }
}
