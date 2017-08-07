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
            page = PageViewTangoEdit( parentView: mTopView,
                                  title: UResourceManager.getStringByName("title_edit"))
            break
        case .StudyBookSelect:    // 学習する単語帳を選択する
            page = PageViewStudyBookSelect( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_study_select"))
            break
        case .StudySlide:         // 単語帳学習(カードスライド式)
            page = PageViewStudySlide( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_studying_slide"))
            break
        case .StudySelect4:       // 単語帳学習(４択)
            page = PageViewStudySelect4( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_studying_select"))
            break
        case .StudyInputCorrect:  // 単語帳学習(正解文字入力)
            page = PageViewStudyInputCorrect( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_studying_input_correct"))
            break
        case .StudyResult:        // 単語帳結果
            page = PageViewResult( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_result"))
            break
        case .History:            // 履歴
            page = PageViewHistory( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_history"))
            break
        case .Settings:           // 設定
            page = PageViewSettingsTop( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_settings"))
            break
        case .Options:            // オプション設定
            page = PageViewOptions( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_options"))
            break
        case .BackupDB:           // バックアップ
            page = PageViewBackup( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_backup"))
            break
        case .RestoreDB:          // バックアップから復元
            page = PageViewRestore( parentView: mTopView,
                                      title: UResourceManager.getStringByName("restore"))
            break
        case .PresetBook:         // プリセット単語帳選択
            page = PageViewPresetBook( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_preset_book"))
            break
        case .CsvBook:            // Csv単語帳選択
            page = PageViewCsvBook( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_csv_book"))
            break
//        case .SearchCard:         // カード検索
//            page = PageViewTangoEdit( parentView: mTopView,
//                                      title: UResourceManager.getStringByName("title_edit"))
//            break
        case .Help:               // ヘルプ
//            page = PageViewTangoEdit( parentView: mTopView,
//                                      title: UResourceManager.getStringByName("title_edit"))
            break
        case .License:            // ライセンス表示
//            page = PageViewTangoEdit( parentView: mTopView,
//                                      title: UResourceManager.getStringByName("title_edit"))
            break
        case .Debug:               // Debug
            page = PageViewDebug( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_debug"))
            break
        case .DebugDB:             // Debug DB(Realm)
            page = PageViewDebugDB( parentView: mTopView,
                                      title: UResourceManager.getStringByName("title_debug_db"))
            break
        default:
            break
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
    
     /**
      * 学習ページを表示開始
      * 他のページと異なり引数を受け取る必要があるため関数化
      * @param book
      * @param firstStudy trueならリトライでない学習
      */
    public func startStudyPage( book : TangoBook, firstStudy : Bool) {
         switch( MySharedPref.getStudyMode()) {
         case .SlideOne:
            fallthrough
         case .SlideMulti:
            let pageView = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.StudySlide.rawValue) as! PageViewStudySlide
//             let page = getPageView(pageId: PageIdMain.StudySlide) as! PageViewStudySlide
             pageView.setBook(book: book)
             pageView.isFirst = firstStudy
//             stackPage(PageView.StudySlide)
         
//         case .Choice4:
//             let page = getPageView(PageView.StudySelect4) as! PageViewStudySelect4
//             page.setBook(book)
//             page.setFirstStudy(firstStudy)
//             stackPage(PageView!.StudySelect4)
//         
//         case .Input:
//             PageViewStudyInputCorrect page = (PageViewStudyInputCorrect)getPageView(PageView
//                     .StudyInputCorrect);
//             page.setBook(book);
//             page.setFirstStudy(firstStudy);
//             stackPage(PageView.StudyInputCorrect);
         default:
            break
         }
    }
    
    /**
    * 学習ページを表示開始(リトライ時)
    * @param book
    * @param cards  リトライで学習するカード
    */
    public func startStudyPage( book : TangoBook, cards : List<TangoCard>, stack : Bool )
    {
    
    //         PageView pageView = null;
    //         switch( MySharedPref.getStudyMode()) {
    //             case SlideOne:
    //             case SlideMulti: {
    //                 pageView = PageView.StudySlide;
    //                 PageViewStudySlide page = (PageViewStudySlide) getPageView(pageView);
    //                 page.setBook(book);
    //                 page.setCards(cards);
    
    //                 if (stack) {
    //                     stackPage(pageView);
    //                 } else {
    //                     changePage(pageView);
    //                 }
    //             }
    //                 break;
    //             case Choice4: {
    //                 pageView = PageView.StudySelect4;
    //                 PageViewStudySelect4 page = (PageViewStudySelect4) getPageView(pageView);
    //                 page.setBook(book);
    //                 page.setCards(cards);
    
    //                 if (stack) {
    //                     stackPage(pageView);
    //                 } else {
    //                     changePage(pageView);
    //                 }
    //             }
    //                 break;
    //             case Input: {
    //                 pageView = PageView.StudyInputCorrect;
    //                 PageViewStudyInputCorrect page = (PageViewStudyInputCorrect) getPageView(pageView);
    //                 page.setBook(book);
    //                 page.setCards(cards);
    
    //                 if (stack) {
    //                     stackPage(pageView);
    //                 } else {
    //                     changePage(pageView);
    //                 }
    //             }
    //                 break;
    //         }
    
    //         if (pageView != null) {
    
    //         }
    }
    
    /**
    * リザルトページを開始
    * 他のページと異なり引数を受け取る必要があるため関数化
    */
    public func startStudyResultPage( book : TangoBook, okCards : List<TangoCard>, ngCards : List<TangoCard>)
    {
    //         PageViewResult page = (PageViewResult)getPageView(PageView.StudyResult);
    //         page.setBook(book);
    //         page.setCardsLists(okCards, ngCards);
    //         changePage(PageView.StudyResult);
    }
    
    /**
     * オプション設定ページを表示
     */
    public func startOptionPage( mode : PageViewOptions.Mode) {
        // todo
//        var pageView = stackPage(pageId: PageIdMain.Options.rawValue) as! PageViewOptions
//        pageView.setMode(mode)
    }
}
