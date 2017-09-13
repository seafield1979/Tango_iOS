//
//  UPageViewManager.swift
//  UGui
//      各ページを管理するクラス
//      現在のページ番号を元に配下の PageView の処理を呼び出す
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class UPageViewManager {
    // MARK: Properties
    var mTopScene : TopScene
    var mParentVC : UIViewController? = nil
    var pageStack : List<UPageView> = List()
    var returnButton : UIBarButtonItem?      // ナビゲーションバーに表示する戻るボタン
    var actionButton : UIBarButtonItem?     // ナビゲーションバーの右側に表示するボタン
    
    // MARK: Accessor
    public func getViewController() -> UIViewController {
        return mParentVC!
    }
    
    /**
     * ナビゲーションバーの右側に表示するボタンのタイトルを設定する
     */
    public func setActionButtonTitle(_ title : String) {
        if let button = actionButton {
            button.title = title
        }
    }
    
    // MARK: Initializer
    init(topScene : TopScene, vc: UIViewController?) {
        mTopScene = topScene
        mParentVC = vc
        
        // 戻るボタン
        let text = UResourceManager.getStringByName("return1")
        returnButton = UIBarButtonItem(title: text, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UPageViewManager.clickReturnButton))
        
        // アクションボタン
        let text2 = UResourceManager.getStringByName("action")
        actionButton = UIBarButtonItem(title: text2, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UPageViewManager.clickActionButton))
    }
    
    // MARK: Methods
    /**
     * カレントのページIDを取得する
     * @return カレントページID
     */
    func currentPage() -> UPageView? {
        if pageStack.count == 0 {
            return nil
        }
        return pageStack.last()
    }
    
    /**
     * 配下のページを追加する
     * parameter pageId : ページID
     */
    public func initPage(_ pageId : Int) -> UPageView? {
        // 継承先のクラスで実装
        return nil
    }
    
    /**
     * 描画処理
     * 配下のUViewPageの描画処理を呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    public func draw() -> Bool {
        let pageView = pageStack.last()
        
        return pageView!.draw()
    }
    
    /**
     * バックキーが押されたときの処理
     * @return
     */
    public func onBackKeyDown() -> Bool {
        // 省電力モードを解除
        mTopScene.resetPowerSaving()
        
        // スタックをポップして１つ前の画面に戻る
        let pageView : UPageView? = currentPage()
        if pageView == nil {
            return false
        }
        
        // 各ページで処理
        if (pageView!.onBackKeyDown()) {
            // 何かしら処理がされたら何もしない
            return true
        }
    
        // スタックを１つポップする
        if (pageStack.count > 1) {
            if (popPage()) {
                return true
            }
        }
        // スタックのページが１つだけなら終了
        return false
    }
    
    /**
     * ページ切り替え時に呼ばれる処理
     */
    public func pageChanged() {
        UDrawManager.clearDebugPoint()
        
        UDrawManager.getInstance().removeAll()
        self.mTopScene.removeAllChildren()
        
        // ナビゲーションに表示したボタンは毎回元に戻す
        showActionBarButton(show: false, title: nil)
    }
    
    /**
     * 表示ページを切り替える
     * ページスタックの末尾を削除後、新しいページを追加する
     * @param pageId
     */
    
    public func changePage( pageView : UPageView) {
        pageChanged()
    
        if pageStack.count > 0 {
            // 古いページの後処理(onHide)
            let oldPage : UPageView = pageStack.last()!
            oldPage.onHide()
            
            _ = pageStack.removeLast()
        }
        pageStack.append(pageView)
        
        // 新しいページの前処理(onShow)
        pageView.onShow()
        setActionBarTitle(pageView.getTitle())
    }
    
    // ページIDでPageViewを初期化する
    public func changePage(pageId : Int) -> UPageView {
        
        // ページ生成
        let pageView = initPage(pageId)
        
        changePage(pageView: pageView!)
        
        return pageView!
    }

    /**
     * ページを取得する
     */
    public func getPageView(pageId : Int) -> UPageView {
        return initPage(pageId)!
    }
    
    /**
     * ページをスタックする
     * ソフトウェアキーの戻るボタンを押すと元のページに戻れる
     * @param pageId
     */
    public func stackPage(pageView: UPageView) {
        pageChanged()
        
        // 古いページの後処理
        if pageStack.count > 0 {
            let page : UPageView = pageStack.last()!
            
            page.onHide()
        }
        
        pageStack.append(pageView)
        
        pageView.onShow()
        setActionBarTitle(pageView.getTitle())
        
        // アクションバーに戻るボタンを表示
        if (pageStack.count >= 2) {
            showActionBarBack(show: true)
        }
    }
    
    // ページIDでPageViewを初期化する
    public func stackPage(pageId : Int) -> UPageView {
        
        // ページ生成
        let pageView = initPage(pageId)
        
        stackPage(pageView: pageView!)
        
        return pageView!
    }
    
    /**
     * ページをポップする
     * 下にページがあったら移動
     */
    public func popPage() -> Bool {
        pageChanged()

        if pageStack.count > 0 {
            
            // 古いページの後処理
            let pageView = pageStack.last()!
            
            pageView.onHide()
            
            _ = pageStack.removeLast()
            
            
            // 新しいページの前処理
            let newPage = pageStack.last()!
            newPage.onShow()
            setActionBarTitle(newPage.getTitle())
            
            if pageStack.count <= 1 {
                // 戻るアイコン表示
                showActionBarBack(show: false)
            }
            return true
        }
        return false
    }
    
    /**
     * 外部からアクションIDを受け取る
     * アクションIDを現在表示中のページで処理される
     */
    public func setActionId(id : Int) {
        currentPage()!.setActionId(id)
    }
    
    /**
     * アクションバーの戻るボタン(←)を表示する
     * @param show false:非表示 / true:表示
     */
    private func showActionBarBack(show : Bool) {
        if let _vc = mParentVC {
            if (show) {
                _vc.navigationItem.setLeftBarButton(returnButton, animated: true)
            } else {
                _vc.navigationItem.setLeftBarButton(nil, animated: true)
            }
        }
    }
    
    /**
     * 右のアクションバーを設定する
     */
    public func showActionBarButton(show : Bool, title: String?) {
        if let _vc = mParentVC {
            if (show) {
                if let _title = title {
                    setActionButtonTitle( _title )
                }
                _vc.navigationItem.setRightBarButton(actionButton, animated: true)
            } else {
                _vc.navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }
    
    
    /**
     * アクションバーのタイトル文字を設定する
     * @param text
     */
    public func setActionBarTitle(_ text : String) {
        if let _vc = mParentVC {
            _vc.title = text
        }
    }
    
    /**
     ナビゲーションバーの戻るボタンが押された時の処理
     */
    @objc func clickReturnButton() {
        _ = onBackKeyDown()
    }
    
    /**
     ナビゲーションバーのアクションボタンが押された時の処理
     */
    @objc func clickActionButton() {
        currentPage()!.onActionButton()
    }
}
