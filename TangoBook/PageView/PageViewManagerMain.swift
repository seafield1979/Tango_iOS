//
//  PageViewManager.swift
//  UGui
//     単語帳アプリメインのページマネージャー
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

// ページIDのリスト
public enum PageIdMain : Int, EnumEnumerable {
    case Title              // タイトル画面
    case Edit               // 単語帳を編集
    case StudyBookSelect    // 学習する単語帳を選択する
    case StudySlide         // 単語帳学習(カードスライド式)
    case StudySelect4       // 単語帳学習(４択)
    case StudyInputCorrect  // 単語帳学習(正解文字入力)
    case StudyResult        // 単語帳結果
    case History            // 履歴
    case Settings           // 設定
    case Options            // オプション設定
    case BackupDB           // バックアップ
    case RestoreDB          // バックアップから復元
    case PresetBook         // プリセット単語帳選択
    case CsvBook            // Csv単語帳選択
    case SearchCard         // カード検索
    case Help               // ヘルプ
    case License            // ライセンス表示
    case Debug               // Debug
    case DebugDB             // Debug DB(Realm)
    
    public static func toEnum(_ value : Int) -> PageIdMain {
        if value >= PageIdMain.count {
            // 範囲外は適当な値を返す
            return PageIdMain.Title
        }
        return PageIdMain.cases[value]
    }
}

public class PageViewManagerMain : UPageViewManager {
    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : PageViewManagerMain? = nil
    
    // Singletonオブジェクトを作成する
    public static func createInstance(topView : TopView) -> PageViewManagerMain {
        singleton = PageViewManagerMain(topView: topView)
        return singleton!
    }
    public static func getInstance() -> PageViewManagerMain {
        return singleton!
    }
    
    private override init(topView : TopView) {
        super.init(topView: topView)
        
        // 最初に表示するページ
        _ = stackPage(pageId: PageIdMain.Title.rawValue)
    }
    
    /**
     * 配下のページを追加する
     */
    override public func initPage(_ pageId : Int) -> UPageView? {
        var page : UPageView? = nil
        
        switch PageIdMain.toEnum(pageId) {
        case .Title:              // タイトル画面
            page = PageViewTitle( parentView: mTopView,
                                  title: UResourceManager.getStringByName("app_title"))
            break
        case .Edit:               // 単語帳を編集
            break
        case .StudyBookSelect:    // 学習する単語帳を選択する
            break
        case .StudySlide:         // 単語帳学習(カードスライド式)
            break
        case .StudySelect4:       // 単語帳学習(４択)
            break
        case .StudyInputCorrect:  // 単語帳学習(正解文字入力)
            break
        case .StudyResult:        // 単語帳結果
            break
        case .History:            // 履歴
            break
        case .Settings:           // 設定
            break
        case .Options:            // オプション設定
            break
        case .BackupDB:           // バックアップ
            break
        case .RestoreDB:          // バックアップから復元
            break
        case .PresetBook:         // プリセット単語帳選択
            break
        case .CsvBook:            // Csv単語帳選択
            break
        case .SearchCard:         // カード検索
            break
        case .Help:               // ヘルプ
            break
        case .License:            // ライセンス表示
            break
        case .Debug:               // Debug
            break
        case .DebugDB:             // Debug DB(Realm)
            break
//        case .TestTitle:              // タイトル画面
//            page = PageViewTitle( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("app_title"))
//        case .Test1:
//            page = PageViewTest1( parentView: mTopView,
//                        title: UResourceManager.getStringByName("test1"))
//        case .Test2:
//            page = PageViewTest2( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("test2"))
//        case .Test3:
//            page = PageViewTest3( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("test3"))
//        case .Test4:
//            page = PageViewTest4( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("test4"))
//        case .Test5:
//            page = PageViewTest5( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("test5"))
//        case .Test6:
//            page = PageViewTest6( parentView: mTopView,
//                                  title: UResourceManager.getStringByName("test6"))
        }
        return page
    }
    
    /**
     * ページ切り替え時に呼ばれる処理
     */
    override public func pageChanged(pageId : Int) {
        super.pageChanged(pageId: pageId)

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