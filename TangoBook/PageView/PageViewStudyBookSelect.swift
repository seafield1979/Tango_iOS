//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * Created by shutaro on 2016/12/16.
 *
 * 学習する単語帳を選択するページ(リストビュー版)
 */

public class PageViewStudyBookSelect : UPageView
        , UButtonCallbacks, UListItemCallbacks, UWindowCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewStudyBookSelect"
    
    /**
     * Constants
     */
    private let DRAW_PRIORITY = 100

    private let MARGIN_H = 17
    private let MARGIN_V_S = 10

    private let TEXT_SIZE = 17

    // Button Ids
    private let ButtonIdReturn = 100

    // 開始ダイアログ(PreStudyWindow)でボタンが押されたときに使用する
    public static let ButtonIdStartStudy = 2001
    public static let ButtonIdCancel = 2002

    /**
     * Member variables
     */
    private var mTitleText : UTextView? = nil
    private var mListView : UListView? = nil
    private var mBook : TangoBook? = nil
    private var mSortMode : IconSortMode = .None

    // 学習開始前のオプション等を選択するダイアログ
    private var mPreStudyWindow : PreStudyWindow? = nil

    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public override init( parentView : TopView, title : String) {
        super.init( parentView: parentView, title: title)

        mSortMode = IconSortMode.toEnum(MySharedPref.readInt(MySharedPref
                .StudyBookSortKey));
    }

    /**
     * Methods
     */
    
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool{
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }

    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch) -> Bool {

        return false
    }

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        UDrawManager.getInstance().initialize()

        let width = mTopView.getWidth()
        let height = mTopView.getHeight()

        let x = UDpi.toPixel(MARGIN_H)
        var y = UDpi.toPixel(MARGIN_V_S)

        // ListViewにアイテムを追加
        let books : [TangoItem]? = TangoItemPosDao.selectItemsByParentTypeWithSort(
                parentType : TangoParentType.Home, parentId : 0,
                itemType : TangoItemType.Book, sortMode : mSortMode,
                changeable : true)

        if books == nil || books!.count == 0 {
            // リストが空
            mListView = nil
            y += UDpi.toPixel(67)
            let text = UTextView.createInstance(
                text : UResourceManager.getStringByName("no_study_history"),
                textSize : Int(UDpi.toPixel(TEXT_SIZE)), priority : DRAW_PRIORITY-1,
                alignment : UAlignment.CenterX, multiLine : false, isDrawBG : false,
                x : width/2, y : y, width : width, color : UIColor.black, bgColor : nil)
            text.addToDrawManager()

        } else {
            // Title
            mTitleText = UTextView.createInstance(
                text : UResourceManager.getStringByName("title_study2"),
                textSize : Int(UDpi.toPixel(TEXT_SIZE)), priority : DRAW_PRIORITY,
                alignment : UAlignment.CenterX, multiLine : false,
                isDrawBG : false, x : width/2, y : y, width : width,
                color : UIColor.black, bgColor : nil)
            mTitleText!.addToDrawManager()
            y += mTitleText!.getHeight() + UDpi.toPixel(MARGIN_V_S)

            // ListView
            let listViewH = height - (UDpi.toPixel(MARGIN_V_S) * 3 + mTitleText!.getHeight())
            mListView = UListView(parentView : mTopView, windowCallbacks : nil,
                                  listItemCallbacks : self, priority : DRAW_PRIORITY,
                                  x : x, y : y,
                                  width : width-UDpi.toPixel(MARGIN_H)*2,
                                  height : listViewH, color : UIColor.white)
            mListView!.setFrameColor(frameColor: UIColor.black)
            mListView!.addToDrawManager()

            for book in books! {
                let _book = book as! TangoBook
                let listItem = ListItemStudyBook(listItemCallbacks : self, book : _book, width : mListView!.getWidth(), color : UIColor.white)
                mListView!.add(item: listItem)
            }
            // スクロールバー等のサイズを更新
            mListView!.updateWindow()

            y += listViewH + UDpi.toPixel(MARGIN_V_S)

            // PreStudyWindow 学習開始前に設定を行うウィンドウ
            mPreStudyWindow = PreStudyWindow(windowCallbacks : self, buttonCallbacks : self, parentView : mTopView)
            mPreStudyWindow!.addToDrawManager()
        }
    }

    /**
     * アクションIDを処理する
     * サブクラスでオーバーライドして使用する
     */
    public func setActionId( id : Int ) {
//        switch (id) {
//        case R.id.action_sort_none:
//            mSortMode = IconSortMode.None;
//            break;
//        case R.id.action_sort_word_asc:
//            mSortMode = IconSortMode.TitleAsc;
//            break;
//        case R.id.action_sort_word_desc:
//            mSortMode = IconSortMode.TitleDesc;
//            break;
//        case R.id.action_sort_time_asc:
//            mSortMode = IconSortMode.CreateTimeAsc;
//            break;
//        case R.id.action_sort_time_desc:
//            mSortMode = IconSortMode.CreateTimeDesc;
//            break;
//        case R.id.action_sort_studied_time_asc:
//            mSortMode = IconSortMode.StudiedTimeAsc;
//            break;
//        case R.id.action_sort_studied_time_desc:
//            mSortMode = IconSortMode.StudiedTimeDesc;
//            break;
//        default:
//            return;
//        }
//        MySharedPref.writeInt(MySharedPref.StudyBookSortKey, mSortMode.ordinal());
//        isFirst = true;
//        mParentView.invalidate();
    }
        
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool{
        if mPreStudyWindow != nil {
            if mPreStudyWindow!.onBackKeyDown() {
                return true
            }
            else if mPreStudyWindow!.isShow {
                mPreStudyWindow!.isShow = false
                return true
            }
        }

        return false
    }
    
    /**
     * Callbacks
     */

    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch id {
        case ButtonIdReturn:
            _ = PageViewManagerMain.getInstance().popPage()
            
        case PageViewStudyBookSelect.ButtonIdStartStudy:
            // 学習開始
            PageViewManagerMain.getInstance().startStudyPage( book: mBook!, firstStudy: true)
            
        case PageViewStudyBookSelect.ButtonIdCancel:
            mPreStudyWindow!.isShow = false
        default:
            break
        }
        return false
    }
    
    /**
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
        public func ListItemClicked( item : UListItem) {
        // 学習開始前のダイアログを表示する
        if !(item is ListItemStudyBook) {
            return
        }

        let bookItem = item as! ListItemStudyBook

        mPreStudyWindow!.showWithBook(book: bookItem.getBook()!)
        mBook = bookItem.getBook()
    }
    
    public func ListItemButtonClicked( item : UListItem, buttonId : Int) {

    }

    /**
     * UWindowCallbacks
     */
    public func windowClose( window : UWindow) {
        // Windowを閉じる
        if mPreStudyWindow === window {
            mPreStudyWindow!.isShow = false
        }
    }
}
