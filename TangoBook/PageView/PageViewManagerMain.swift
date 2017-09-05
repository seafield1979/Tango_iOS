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
    public static func createInstance(topScene : TopScene, vc: UIViewController?) -> PageViewManagerMain {
        singleton = PageViewManagerMain(topScene: topScene, vc : vc)
        singleton?.mParentVC = vc
        return singleton!
    }
    public static func getInstance() -> PageViewManagerMain {
        return singleton!
    }
    
    private override init(topScene : TopScene, vc : UIViewController?) {
        super.init(topScene: topScene, vc: vc)
        
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
            page = PageViewTitle( topScene: mTopScene,
                                  title: UResourceManager.getStringByName("app_title"))
            break
        case .Edit:               // 単語帳を編集
            page = PageViewTangoEdit( topScene: mTopScene,
                                  title: UResourceManager.getStringByName("title_edit"))
            break
        case .StudyBookSelect:    // 学習する単語帳を選択する
            page = PageViewStudyBookSelect( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_study_select"))
            break
        case .StudySlide:         // 単語帳学習(カードスライド式)
            page = PageViewStudySlide( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_studying_slide"))
            break
        case .StudySelect4:       // 単語帳学習(４択)
            page = PageViewStudySelect4( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_studying_select"))
            break
        case .StudyInputCorrect:  // 単語帳学習(正解文字入力)
            page = PageViewStudyInputCorrect( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_studying_input_correct"))
            break
        case .StudyResult:        // 単語帳結果
            page = PageViewResult( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_result"))
            break
        case .History:            // 履歴
            page = PageViewHistory( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_history"))
            break
        case .Settings:           // 設定
            page = PageViewSettingsTop( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_settings"))
            break
        case .Options:            // オプション設定
            page = PageViewOptions( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_options"))
            break
        case .BackupDB:           // バックアップ
            page = PageViewBackup( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_backup"))
            break
        case .RestoreDB:          // バックアップから復元
            page = PageViewRestore( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("restore"))
            break
        case .PresetBook:         // プリセット単語帳選択
            page = PageViewPresetBook( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_preset_book"))
            break
        case .CsvBook:            // Csv単語帳選択
            page = PageViewCsvBook( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_csv_book"))
            break
//        case .SearchCard:         // カード検索
//            page = PageViewTangoEdit( topScene: mTopScene,
//                                      title: UResourceManager.getStringByName("title_edit"))
//            break
        case .Help:               // ヘルプ
//            page = PageViewTangoEdit( topScene: mTopScene,
//                                      title: UResourceManager.getStringByName("title_edit"))
            break
        case .License:            // ライセンス表示
//            page = PageViewTangoEdit( topScene: mTopScene,
//                                      title: UResourceManager.getStringByName("title_edit"))
            break
        case .Debug:               // Debug
            page = PageViewDebug( topScene: mTopScene,
                                      title: UResourceManager.getStringByName("title_debug"))
            break
        case .DebugDB:             // Debug DB(Realm)
            page = PageViewDebugDB( topScene: mTopScene,
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
    override public func pageChanged() {
        super.pageChanged()

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
             let pageView = getPageView(pageId: PageIdMain.StudySlide.rawValue) as! PageViewStudySlide
             pageView.setBook(book)
             pageView.isFirst = firstStudy
             stackPage(pageView: pageView)
         
        case .Choice4:
            let pageView = getPageView(pageId: PageIdMain.StudySelect4.rawValue) as! PageViewStudySelect4
            pageView.setBook(book)
            pageView.setFirstStudy(firstStudy)
            stackPage(pageView: pageView)
            
        case .Input:
            let pageView = getPageView(pageId: PageIdMain.StudyInputCorrect.rawValue) as! PageViewStudyInputCorrect
            pageView.setBook(book)
            pageView.setFirstStudy(firstStudy)
            stackPage(pageView: pageView)
            break
        }
    }
    
    /**
    * 学習ページを表示開始(リトライ時)
    * @param book
    * @param cards  リトライで学習するカード
    */
    public func startStudyPage( book : TangoBook, cards : List<TangoCard>?, stack : Bool , isFirst : Bool)
    {
        var pageId : PageIdMain
        
        switch( MySharedPref.getStudyMode()) {
        case .SlideOne:
            fallthrough
        case .SlideMulti:
            pageId = PageIdMain.StudySlide
            let page : PageViewStudySlide = getPageView(pageId: pageId.rawValue) as! PageViewStudySlide
            page.setBook(book)
            page.setCards(cards)
            page.setFirstStudy(isFirst)

            if stack {
                stackPage(pageView: page)
            } else {
                changePage(pageView: page)
            }
        
        case .Choice4:
            pageId = PageIdMain.StudySelect4
            let page : PageViewStudySelect4 = getPageView(pageId: pageId.rawValue) as! PageViewStudySelect4
            page.setBook(book)
            page.setCards(cards)
            page.setFirstStudy(isFirst)
            
            if stack {
                stackPage(pageView: page)
            } else {
                changePage(pageView: page)
            }
            break
        case .Input:
            pageId = PageIdMain.StudyInputCorrect
            let page : PageViewStudyInputCorrect = getPageView(pageId: pageId.rawValue) as! PageViewStudyInputCorrect
            page.setBook(book)
            page.setCards(cards!)
            page.setFirstStudy(isFirst)
            
            if stack {
                stackPage(pageView: page)
            } else {
                changePage(pageView: page)
            }
            break
        }
    }
    
    /**
    * リザルトページを開始
    * 他のページと異なり引数を受け取る必要があるため関数化
    */
    public func startStudyResultPage( book : TangoBook, okCards : List<TangoCard>, ngCards : List<TangoCard>)
    {
        let page : PageViewResult = getPageView(pageId: PageIdMain.StudyResult.rawValue) as! PageViewResult
        page.setBook(mBook: book)
        page.setCardsLists(okCards: okCards, ngCards: ngCards)
        changePage( pageView: page)
    }
    
    /**
     * オプション設定ページを表示
     */
    public func startOptionPage( mode : PageViewOptions.Mode) {
        let page : PageViewOptions = stackPage(pageId: PageIdMain.Options.rawValue) as! PageViewOptions
        
        page.setMode(mode: mode)
        changePage( pageView: page)
    }
}
