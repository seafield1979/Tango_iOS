//
//  PageViewManagerTest1.swift
//  TangoBook
//    GUIテスト用のPageViewManager
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

// ページIDのリスト
public enum PageIdTest1 : Int, EnumEnumerable {
    case Title              // タイトル画面
    case Test1              // ボタン
    case Test2
    case Test3              // ログウィンドウ
    case Test4              // メニューバー
    case Test5              // スクロールバー
    case Test6
    
    public static func toEnum(_ value : Int) -> PageIdTest1 {
        if value >= PageIdTest1.count {
            // 範囲外は適当な値を返す
            return PageIdTest1.Title
        }
        return PageIdTest1.cases[value]
    }
}

public class PageViewManagerTest1 : UPageViewManager {
    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : PageViewManagerTest1? = nil
    
    // Singletonオブジェクトを作成する
    public static func createInstance(topView : TopView) -> PageViewManagerTest1
    {
        singleton = PageViewManagerTest1(topView: topView)
        return singleton!
    }
    public static func getInstance() -> PageViewManagerTest1 {
        return singleton!
    }
    
    private override init(topView : TopView) {
        super.init(topView: topView)
        
        // 最初に表示するページ
        _ = stackPage(pageId: PageIdTest1.Title.rawValue)
    }
    
    /**
     * 配下のページを追加する
     */
    override public func initPage(_ pageId : Int) -> UPageView? {
        var page : UPageView? = nil
        
        switch PageIdTest1.toEnum(pageId) {
        case .Title:              // タイトル画面
            page = PageViewTitle( parentView: mTopView,
                                  title: UResourceManager.getStringByName("app_title"))
        case .Test1:
            page = PageViewTest1( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test1"))
        case .Test2:
            page = PageViewTest2( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test2"))
        case .Test3:
            page = PageViewTest3( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test3"))
        case .Test4:
            page = PageViewTest4( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test4"))
        case .Test5:
            page = PageViewTest5( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test5"))
        case .Test6:
            page = PageViewTest6( parentView: mTopView,
                                  title: UResourceManager.getStringByName("test6"))
        }
        
        return page
    }
    
    /**
     * ページ切り替え時に呼ばれる処理
     */
    override public func pageChanged(pageId : Int) {
        super.pageChanged(pageId: pageId)
    }
    
}
