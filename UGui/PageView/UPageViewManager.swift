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
    /**
     * Enums
     */
    /**
     * Consts
     */
    
    /**
     * Member Variables
     */
    var mTopScene : TopScene
    var mParentVC : UIViewController? = nil
    var pageStack : List<UPageView> = List()
    var returnButton : UIBarButtonItem?      // ナビゲーションバーに表示する戻るボタン
    
    /**
     * Get/Set
     */
    
    /**
     * Constructor
     */
    init(topScene : TopScene, vc: UIViewController?) {
        // 最初にページのリストに全ページ分の要素を追加しておく
//        for _ in PageView.cases {
//            pages.append(nil)
//        }
        mTopScene = topScene
        mParentVC = vc
        
        // 戻るボタン
        returnButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UPageViewManager.clickReturnButton))
    }
    
    /**
     * Methods
     */
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
    public func pageChanged(pageId: Int) {
        UDrawManager.clearDebugPoint()
        
        self.mTopScene.removeAllChildren()
    }
    
    /**
     * 表示ページを切り替える
     * ページスタックの末尾を削除後、新しいページを追加する
     * @param pageId
     */
    public func changePage(_ pageId : Int) {
        pageChanged(pageId: pageId)
    
        // ページが未初期化なら初期化
        let newPage = initPage(pageId)
        if newPage == nil {
            return
        }
        
        if pageStack.count > 0 {
            // 古いページの後処理(onHide)
            let oldPage : UPageView = pageStack.last()!
            oldPage.onHide()
            
            _ = pageStack.removeLast()
        }
        pageStack.append(newPage!)
        
        // 新しいページの前処理(onShow)
        newPage!.onShow()
        setActionBarTitle(newPage!.getTitle())
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
    public func stackPage(pageId : Int) -> UPageView {
        pageChanged(pageId: pageId)
    
        // ページ初期化
        let newPage = initPage(pageId)
        
        // 古いページの後処理
        if (pageStack.count > 0) {
            let page : UPageView = pageStack.last()!
            page.onHide()
        }
        
        pageStack.append(newPage!)
        
        newPage!.onShow()
        setActionBarTitle(newPage!.getTitle())
        
        // アクションバーに戻るボタンを表示
        if (pageStack.count >= 2) {
            showActionBarBack(show: true)
        }
        return newPage!
    }
    
    /**
     * ページをポップする
     * 下にページがあったら移動
     */
    public func popPage() -> Bool {
        if pageStack.count > 0 {
            // 古いページの後処理
            let pageView = pageStack.last()!
            pageView.onHide()
            
            _ = pageStack.removeLast()
            
            // SpriteKit
            mTopScene.removeAllChildren()
            
            // 新しいページの前処理
            let newPage = pageStack.last()!
            newPage.onShow()
            setActionBarTitle(newPage.getTitle())
            
            if pageStack.count <= 1 {
                // 戻るアイコン表示
                showActionBarBack(show: false)
            }
//            changePage(newPage)
            
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
        // Todo iOSではナビゲーションバー
        if let _vc = mParentVC {
            if (show) {
                _vc.navigationItem.setLeftBarButton(returnButton, animated: true)
            } else {
                _vc.navigationItem.setLeftBarButton(nil, animated: true)
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
}
