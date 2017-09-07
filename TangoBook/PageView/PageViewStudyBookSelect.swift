//
//  PageViewBackup.swift
//  TangoBook
//      アクションIDを処理する
//      学習する単語帳を選択するページ(リストビュー版)
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public enum TangoStudyBookActionId : Int, EnumEnumerable {
    case action_sort_none
    case action_sort_word_asc
    case action_sort_word_desc
    case action_sort_studied_time_asc
    case action_sort_studied_time_desc
}

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
    private let DRAW_PRIORITY = 1

    private let MARGIN_H = 17
    private let MARGIN_V_S = 10

    private let FONT_SIZE = 17

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
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.StudyBookSelect.rawValue, title: title)

        mSortMode = IconSortMode.toEnum(MySharedPref.readInt(MySharedPref
                .StudyBookSortKey));
    }

    /**
     * Methods
     */
    
    override func onShow() {
        // ナビゲーションバーにボタンを表示
        PageViewManagerMain.getInstance().showActionBarButton(show: true, title: UResourceManager.getStringByName("sort"))
    }
    
    override func onHide() {
        super.onHide();
    }
    
    /**
     * アクションボタンが押された時の処理
     *　サブクラスでオーバーライドする
     */
    override func onActionButton() {
        // ポップアップを表示
        let ac = UIAlertController(title: UResourceManager.getStringByName("sort"), message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: UResourceManager.getStringByName("cancel"), style: .cancel) { (action) -> Void in
            // なにもしない
        }
        
        let sortWordAsc = UIAlertAction(title: UResourceManager.getStringByName("sort_word_asc_2"), style: .default) { (action) -> Void in
            self.setActionId( .action_sort_word_asc )
        }

        let sortWordDesc = UIAlertAction(title: UResourceManager.getStringByName("sort_word_desc_2"), style: .default) { (action) -> Void in
            self.setActionId( .action_sort_word_desc )
        }
        let sortTimeAsc = UIAlertAction(title: UResourceManager.getStringByName("sort_studied_time_asc"), style: .default) { (action) -> Void in
            self.setActionId( .action_sort_studied_time_asc )
        }
        let sortTimeDesc = UIAlertAction(title: UResourceManager.getStringByName("sort_studied_time_desc"), style: .default) { (action) -> Void in
            self.setActionId( .action_sort_studied_time_desc )
        }
        
        ac.addAction(cancelAction)
        ac.addAction(sortWordAsc)
        ac.addAction(sortWordDesc)
        ac.addAction(sortTimeAsc)
        ac.addAction(sortTimeDesc)
        
        PageViewManagerMain.getInstance().getViewController().present(
            ac, animated: true, completion: nil)
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
        
        mTopScene.removeAllChildren()

        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

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
                fontSize : UDpi.toPixel(FONT_SIZE), priority : DRAW_PRIORITY-1,
                alignment : UAlignment.CenterX, createNode: true,
                multiLine : false, isDrawBG : false,
                x : width/2, y : y, width : width, color : .black, bgColor : nil)
            text.addToDrawManager()

        } else {
            // Title
            mTitleText = UTextView.createInstance(
                text : UResourceManager.getStringByName("title_study2"),
                fontSize : UDpi.toPixel(FONT_SIZE), priority : DRAW_PRIORITY,
                alignment : UAlignment.CenterX, createNode: true,
                multiLine : false, isDrawBG : false,
                x : width/2, y : y, width : width,
                color : .black, bgColor : nil)
            mTitleText!.addToDrawManager()
            y += mTitleText!.getHeight() + UDpi.toPixel(MARGIN_V_S)

            // ListView
            let listViewH = height - (UDpi.toPixel(MARGIN_V_S) * 3 + mTitleText!.getHeight())
            mListView = UListView(topScene : mTopScene, windowCallbacks : nil,
                                  listItemCallbacks : self, priority : DRAW_PRIORITY,
                                  x : x, y : y,
                                  width : width-UDpi.toPixel(MARGIN_H)*2,
                                  height : listViewH, bgColor : UIColor.white)
            mListView!.setFrameColor(.gray)
            mListView!.addToDrawManager()

            for book in books! {
                let _book = book as! TangoBook
                let listItem = ListItemStudyBook(listItemCallbacks : self, book : _book, width : mListView!.getWidth(), bgColor : UIColor.white)
                mListView!.add(item: listItem)
            }
            // スクロールバー等のサイズを更新
            mListView!.updateWindow()

            y += listViewH + UDpi.toPixel(MARGIN_V_S)

            // PreStudyWindow 学習開始前に設定を行うウィンドウ
            mPreStudyWindow = PreStudyWindow(windowCallbacks : self, buttonCallbacks : self, topScene : mTopScene)
            mPreStudyWindow!.addToDrawManager()
        }
    }

    public func setShowPreStudyWindow(_ show : Bool) {
        if show {
            mPreStudyWindow!.isShow = true
            // 隠されていたものを再表示
            mListView?.parentNode.isHidden = true
        } else {
            mPreStudyWindow!.isShow = false
            // 隠されていたものを再表示
            mListView?.parentNode.isHidden = false
        }
    }
    /**
     * アクションIDを処理する
     * サブクラスでオーバーライドして使用する
     */
    public func setActionId( _ id : TangoStudyBookActionId ) {
        
        switch id {
        case .action_sort_none:
            mSortMode = IconSortMode.None
            
        case .action_sort_word_asc:
            mSortMode = IconSortMode.TitleAsc
            
        case .action_sort_word_desc:
            mSortMode = IconSortMode.TitleDesc
            
        case .action_sort_studied_time_asc:
            mSortMode = IconSortMode.StudiedTimeAsc;
            
        case .action_sort_studied_time_desc:
            mSortMode = IconSortMode.StudiedTimeDesc;
            
        }
        
        MySharedPref.writeInt( key: MySharedPref.StudyBookSortKey, value: mSortMode.rawValue)
        isFirst = true
        
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
                setShowPreStudyWindow(false)
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
            setShowPreStudyWindow(false)
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
        setShowPreStudyWindow(true)
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
            setShowPreStudyWindow(false)
        }
    }
}
