//
//  PageViewManager.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

// ページIDのリスト
public enum PageView : Int, EnumEnumerable {
    case Title = 0   // タイトル画面
    case Test1      // ボタン
    case Test2
    case Test3      // ログウィンドウ
    case Test4      // メニューバー
    case Test5      // スクロールバー
    case Test6
   ;
}

public class PageViewManager : UPageViewManager {
    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : PageViewManager? = nil
    
    // Singletonオブジェクトを作成する
    public static func createInstance(topView : TopView) -> PageViewManager {
        singleton = PageViewManager(topView: topView)
        return singleton!
    }
    public static func getInstance() -> PageViewManager {
        return singleton!
    }
    
    private override init(topView : TopView) {
        super.init(topView: topView)
        
        // 最初に表示するページ
        _ = stackPage(pageId: PageView.Title)
    }
    
    /**
     * 配下のページを追加する
     */
    override public func initPage(_ pageView : PageView) {
        var page : UPageView? = nil
        
        switch(pageView) {
        case .Title:              // タイトル画面
            page = PageViewTitle( topView: mTopView,
                                  title: UResourceManager.getStringByName("app_title"))
        case .Test1:
            page = PageViewTest1( topView: mTopView,
                        title: UResourceManager.getStringByName("test1"))
        case .Test2:
            page = PageViewTest2( topView: mTopView,
                                  title: UResourceManager.getStringByName("test2"))
        case .Test3:
            page = PageViewTest3( topView: mTopView,
                                  title: UResourceManager.getStringByName("test3"))
        case .Test4:
            page = PageViewTest4( topView: mTopView,
                                  title: UResourceManager.getStringByName("test4"))
        case .Test5:
            page = PageViewTest5( topView: mTopView,
                                  title: UResourceManager.getStringByName("test5"))
        case .Test6:
            page = PageViewTest6( topView: mTopView,
                                  title: UResourceManager.getStringByName("test6"))
        }
        if page != nil {
            pages[pageView.rawValue] = page
        }
    }
    
    /**
     * ページ切り替え時に呼ばれる処理
     */
    public func pageChanged(pageId : PageView) {
        super.pageChanged(pageId)

        // Todo
//        switch(pageId) {
//        case Edit:
//            MainActivity.getInstance().setMenuType(MainActivity.MenuType.TangoEdit);
//            break;
//        case StudyBookSelect:
//            MainActivity.getInstance().setMenuType(MainActivity.MenuType.SelectStudyBook);
//            break;
//        case CsvBook:
//            MainActivity.getInstance().setMenuType(MainActivity.MenuType.AddCsv);
//            break;
//        case History:
//            MainActivity.getInstance().setMenuType(MainActivity.MenuType.StudiedHistory);
//            break;
//        default:
//            MainActivity.getInstance().setMenuType(MainActivity.MenuType.None);
//        }
    }
    
}
