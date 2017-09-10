//
//  PageViewBackup.swift
//  TangoBook
//      履歴ページ
//      過去に学習した単語帳のリストを表示する
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewHistory : UPageView, UDialogCallbacks, UButtonCallbacks, UListItemCallbacks {

    // MARK: Constants
    private let DRAW_PRIORYTY_DIALOG = 50;

    // layout
    private let TOP_Y = 14;
    private let TEXT_SIZE = 17;

    // button ids
    private let ButtonIdReturn = 100;
    private let ButtonIdClearOK = 102;
    
    // action id
    private let action_clear_history = 200

    // MARK: Properties
    private var mListView : ListViewStudyHistory?
    private var mDialog : UDialogWindow?      // OK/NGのカード一覧を表示するダイアログ

    public static let TAG = "PageViewHistory"
    
    // MARK: Initializer
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.History.rawValue, title: title)
    }

    /**
     * Methods
     */
    public override func onShow() {
        // ナビゲーションバーにボタンを表示
        PageViewManagerMain.getInstance().showActionBarButton(show: true, title: UResourceManager.getStringByName("clear"))
    }

    public override func onHide() {
        super.onHide()
    }

    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @return
     */
    public override func draw() -> Bool {
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
    public func touchEvent(vt : ViewTouch) -> Bool{

        return false
    }
    

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        UDrawManager.getInstance().initialize()

        let width : CGFloat = mTopScene.getWidth()
        let height : CGFloat = mTopScene.getHeight()

        let x : CGFloat = UDpi.toPixel(UPageView.MARGIN_H)
        var y : CGFloat = UDpi.toPixel(TOP_Y)

        // ListView
        let listViewH = height - UDpi.toPixel(UPageView.MARGIN_H) * 2
        mListView = ListViewStudyHistory(
            topScene : mTopScene, listItemCallbacks : self, priority : 1,
            x : x, y : y,
            width : width - UDpi.toPixel(UPageView.MARGIN_H) * 2, height : listViewH,
            color : nil)
        
        if mListView!.getItemNum() > 0 {
            mListView!.setFrameColor(UIColor.gray)
            mListView!.addToDrawManager()
        } else {
            mListView = nil;
            y += UDpi.toPixel(67)
            let text = UTextView.createInstance(
                text : UResourceManager.getStringByName("no_study_history"),
                fontSize : UDpi.toPixel(TEXT_SIZE),
                priority : 1, alignment : UAlignment.CenterX, createNode : true, isFit : true, isDrawBG : false,
                x : width/2, y : y, width : width, color : UIColor.black, bgColor : nil)
                
            text.addToDrawManager()
        }

        y += listViewH + UDpi.toPixel( UPageView.MARGIN_H )
    }
    

    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool{
        if mDialog != nil {
            mDialog!.closeDialog()
            return true
        }
        return false
    }

    /**
     * アクションボタンが押された時の処理
     *　サブクラスでオーバーライドする
     */
    override func onActionButton() {
        // ポップアップを表示
        let ac = UIAlertController(title: UResourceManager.getStringByName("clear"), message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: UResourceManager.getStringByName("cancel"), style: .cancel) { (action) -> Void in
            // なにもしない
        }
        
        let clearAction = UIAlertAction(title: UResourceManager.getStringByName("clear_history"), style: .default) { (action) -> Void in
            self.setActionId(self.action_clear_history)
        }
        ac.addAction(cancelAction)
        ac.addAction(clearAction)
        
        PageViewManagerMain.getInstance().getViewController().present(
            ac, animated: true, completion: nil)
    }
    
    /**
     * アクションIDを処理する
     * サブクラスでオーバーライドして使用する
     */
    public override func setActionId( _ id : Int) {
        switch id {
        case action_clear_history:
            // クリア確認ダイアログを表示する
            // お問い合わせメールダイアログを表示
            if (mDialog != nil) {
                mDialog!.closeDialog()
            }

            var isEmpty = false
            var title : String, message : String


            if mListView == nil || mListView!.getItemNum() == 0 {
                isEmpty = true
            }
            if (isEmpty) {
                // リストが空の場合はクリアできないメッセージを表示
                title = UResourceManager.getStringByName("error")
                message = UResourceManager.getStringByName("study_list_is_empty1")
            } else {
                // リストがある場合はクリア確認メッセージを表示
                title = UResourceManager.getStringByName("confirm")
                message = UResourceManager.getStringByName("confirm_clear_history")
            }

            mDialog = UDialogWindow.createInstance(
                topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
                buttonDir : UDialogWindow.ButtonDir.Horizontal,
                screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight() )
            
            mDialog!.setTitle(title);
            
            let fontSize : CGFloat = UDpi.toPixel(TEXT_SIZE)
            _ = mDialog!.addTextView(
                text : message, alignment : UAlignment.CenterX,
                isFit : true, isDrawBG : false, fontSize : fontSize,
                textColor : UPageView.TEXT_COLOR, bgColor : nil)

            if isEmpty {
                mDialog!.addCloseButton(text: "OK", textColor: UPageView.TEXT_COLOR, bgColor: UColor.OKButton)
            } else {
                _ = mDialog!.addButton(id : ButtonIdClearOK, text : "OK",
                                   fontSize : fontSize, textColor : UPageView.TEXT_COLOR,
                                   color : UColor.LightGreen)
                
                mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
            }
            mDialog!.addToDrawManager()
            
        default:
            break
        }
    }

    /**
     * クリックされた項目のカードリスト用のダイアログを表示する
     */
    private func showDialog(item : ListItemStudiedBook) {
        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()
        
        if (item.getType() != ListItemStudiedBookType.History) {
            return
        }
        
        let history : TangoBookHistory = item.getBookHistory()
        let cards : [TangoStudiedCard] = TangoStudiedCardDao.selectByHistoryId( history.id )

        mDialog = UDialogWindow.createInstance( topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self, buttonDir : UDialogWindow.ButtonDir.Horizontal, screenW : width, screenH : mTopScene.getHeight())
        
        let listView = ListViewResult(
            topScene : mTopScene, listItemCallbacks : nil, studiedCards : cards,
            studyMode : StudyMode.SlideOne, studyType : StudyType.EtoJ,
            priority : DRAW_PRIORYTY_DIALOG,
            x : 0, y : 0,
            width : mDialog!.getSize().width - UDpi.toPixel(UPageView.MARGIN_H) * 2,
            height : height - UDpi.toPixel(67 + UPageView.MARGIN_H * 2), color : .white)
        
        mDialog!.addDrawable(obj: listView)
        mDialog!.addCloseButton(text: UResourceManager.getStringByName("close"))
        
        mDialog!.addToDrawManager()
    }

    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
        switch id {
        case ButtonIdReturn:
            _ = PageViewManagerMain.getInstance().popPage()
        
        case ButtonIdClearOK:
            TangoBookHistoryDao.deleteAll()
            mListView!.clear()
            mDialog!.closeDialog()
            
        default:
            break
        }
        return false;
    }

    /**
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked( item : UListItem) {
        // クリックされた項目の学習カード一覧を表示する
        if !(item is ListItemStudiedBook) {
            return
        }
        
        // Dialog
        showDialog(item : item as! ListItemStudiedBook)
    }
    

    public func ListItemButtonClicked( item : UListItem, buttonId : Int) {

    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed( dialog : UDialogWindow) {
        if mDialog === dialog {
            mDialog = nil
        }
    }

}
