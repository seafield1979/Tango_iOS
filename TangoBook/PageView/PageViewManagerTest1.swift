//
//  PageViewManagerTest1.swift
//  TangoBook
//    GUIテスト用のPageViewManager
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

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
        _ = stackPage(pageId: PageView.Title)
    }
    
    /**
     * 配下のページを追加する
     */
    override public func initPage(_ pageView : PageView) {
        var page : UPageView? = nil
        
        switch(pageView) {
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
        default:
            break
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
