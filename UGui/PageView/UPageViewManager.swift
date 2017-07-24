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
    var mTopView : TopView
    var mParentVC : UIViewController? = nil
    var pages : List<UPageView?> = List()
    var pageIdStack : List<PageView> = List()   // ページ遷移のスタックを管理。このスタックを元に元のページに戻ることができる
    var returnButton : UIBarButtonItem?      // ナビゲーションバーに表示する戻るボタン
    
    /**
     * Get/Set
     */
    
    /**
     * Constructor
     */
    init(topView : TopView) {
        // 最初にページのリストに全ページ分の要素を追加しておく
        for _ in PageView.cases {
            pages.append(nil)
        }
        mTopView = topView
        
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
    func currentPage() -> PageView? {
        if pageIdStack.count > 0 {
            return pageIdStack.last()
        }
        return nil
    }
    
    /**
     * 配下のページを追加する
     *
     */
    public func initPage(_ pageView : PageView) {
        // 継承先のクラスで実装
    }
    
    /**
     * 描画処理
     * 配下のUViewPageの描画処理を呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    public func draw() -> Bool {
        let pageId : PageView? = currentPage()
        if pageId == nil {
            return false
        }
        
        return pages[pageId!.rawValue]!.draw()
    }
    
    /**
     * バックキーが押されたときの処理
     * @return
     */
    public func onBackKeyDown() -> Bool {
        // スタックをポップして１つ前の画面に戻る
        let pageId : PageView? = currentPage()
        if pageId == nil {
            return false
        }
        
        // 各ページで処理
        if (pages[pageId!.rawValue]!.onBackKeyDown()) {
            // 何かしら処理がされたら何もしない
            return true;
        }
    
        // スタックを１つポップする
        if (pageIdStack.count > 1) {
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
    public func pageChanged(_ pageId : PageView) {
        UDrawManager.clearDebugPoint()
    }
    
    /**
     * 表示ページを切り替える
     * @param pageId
     */
    public func changePage(_ pageId : PageView) {
        pageChanged(pageId);
    
        // ページが未初期化なら初期化
        if (pages[pageId.rawValue] == nil) {
            initPage(pageId)
        }
        
        if (pageIdStack.count > 0) {
            // 古いページの後処理(onHide)
            let page : PageView = pageIdStack.last()!
            pages[page.rawValue]!.onHide()
            
            _ = pageIdStack.removeLast()
            
        }
        pageIdStack.append(pageId)
        
        // 新しいページの前処理(onShow)
        var pageId = pageId     // var に置き換え
        pageId = pageIdStack.last()!
        pages[pageId.rawValue]!.onShow()
        setActionBarTitle(pages[pageId.rawValue]!.getTitle())
    }
    
    /**
     * ページを取得する
     */
    public func getPageView(pageId : PageView) -> UPageView{
        if (pages[pageId.rawValue] == nil) {
            initPage(pageId)
        }
        return pages[pageId.rawValue]!
    }
    
    /**
     * ページをスタックする
     * ソフトウェアキーの戻るボタンを押すと元のページに戻れる
     * @param pageId
     */
    public func stackPage(pageId : PageView) -> UPageView {
        pageChanged(pageId)
    
        // ページが未初期化なら初期化
        if (pages[pageId.rawValue] == nil) {
            initPage(pageId)
        }
        
        // 古いページの後処理
        if (pageIdStack.count > 0) {
            let page : PageView = pageIdStack.last()!
            pages[page.rawValue]?.onHide()
        }
        
        pageIdStack.append(pageId)
        
        let page : UPageView = pages[pageId.rawValue]!
        page.onShow()
        setActionBarTitle(pages[pageId.rawValue]!.getTitle())
        
        // アクションバーに戻るボタンを表示
        if (pageIdStack.count >= 2) {
            showActionBarBack(show: true)
        }
        return page
    }
    
    /**
     * ページをポップする
     * 下にページがあったら移動
     */
    public func popPage() -> Bool {
        if (pageIdStack.count > 0) {
            // 古いページの後処理
            var page : PageView = pageIdStack.last()!
            pages[page.rawValue]?.onHide()
            
            _ = pageIdStack.removeLast()
            
            // 新しいページの前処理
            page = pageIdStack.last()!
            pages[page.rawValue]?.onShow()
            setActionBarTitle(pages[page.rawValue]!.getTitle())
            
            if pageIdStack.count <= 1 {
                showActionBarBack(show: false)
            }
            changePage(page)
            
            return true
        }
        return false
    }
    
    /**
     * 外部からアクションIDを受け取る
     * アクションIDを現在表示中のページで処理される
     */
    public func setActionId(id : Int) {
        getPageView(pageId: currentPage()!).setActionId(id)
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
        mTopView.redraw = true
    }
}
