//
//  PageView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * Created by shutaro on 2016/12/05.
 *
 * UViewPageManager配下のページの基底クラス
 */
public class UPageView {
    /**
     * Consts
     */
//    public static let TAG = "UPagaView"
    
    static let TEXT_COLOR : UIColor = UIColor.black
    static let MARGIN_H : CGFloat = 17
    static let MARGIN_V : CGFloat = 17
    
    /**
     * Member Variables
     */
    public var mTopView : TopView? = nil
    var mTitle : String
    
    // UDrawManagerで描画を行うページ番号
    var isFirst : Bool = true
    
    /**
     * Get/Set
     */
    public func getTitle() -> String {
        return mTitle
    }
    
    /**
     * Constructor
     */
    public init(topView : TopView, title : String) {
        mTopView = topView
        mTitle = title
    }
    
    /**
     * Methods
     */
    /**
     * スタックの先頭になって表示され始める前に呼ばれる
     */
    func onShow() {
    }
    
    /**
     * スタックの先頭でなくなって表示されなくなる前に呼ばれる
     */
    func onHide() {
        isFirst = true
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * アクションIDを処理する
     * サブクラスでオーバーライドして使用する
     */
    public func setActionId(_ id : Int) {
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    func initDrawables() {
        // 抽象メソッド。継承先でオーバーライドして使用してください
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    func onBackKeyDown() -> Bool {
        // 抽象メソッド。継承先でオーバーライドして使用してください
        return false
    }
}
