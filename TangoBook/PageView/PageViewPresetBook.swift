//
//  PageViewBackup.swift
//  TangoBook
//      プリセット単語帳リストを表示、追加するページ
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewPresetBook : UPageView, UButtonCallbacks, UListItemCallbacks, UDialogCallbacks
{
    
    // MARK: Constants
    public static let TAG = "PageViewPresetBook"
    private let DRAW_PRIORITY = 1
    private let DRAW_PRIORYTY_DIALOG = 50

    private let TOP_Y = 10
    private let MARGIN_H = 12
    private let MARGIN_V = 12

    // button id
    private let ButtonIdReturn = 100
    private let ButtonIdAddOk = 200
    private let ButtonIdAddOk2 = 201

    // MARK: Properties
    private var mTitleText : UTextView?
    private var mListView : UListView?
    private var mDialog : UDialogWindow?      // OK/NGのカード一覧を表示するダイアログ
    private var mBook : PresetBook?

    // 終了確認ダイアログ
    private var mConfirmDialog : UDialogWindow?
    private var mMessageDialog : UDialogWindow?

    // MARK: Initializer
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.PresetBook.rawValue, title: title)
        
        PresetBookManager.getInstance().makeBookList()

    }
    
    // MARK: Methods
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide()
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
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
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    override public func initDrawables() {
        UDrawManager.getInstance().initialize()

        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

        let x = UDpi.toPixel(MARGIN_H)
        var y = UDpi.toPixel(TOP_Y)

        // Title
        mTitleText = UTextView.createInstance(
            text : UResourceManager.getStringByName("preset_title2"),
            fontSize : UDraw.getFontSize(FontSize.L), priority : DRAW_PRIORITY,
            alignment : UAlignment.CenterX, createNode : true, isFit : true,
            isDrawBG : false,
            x : width/2, y : y,
            width : width, color : UIColor.black, bgColor : nil)
        
        mTitleText!.addToDrawManager()
        y += mTitleText!.getSize().height + UDpi.toPixel(MARGIN_V)

        // ListView
        let listViewH = height - (UDpi.toPixel(MARGIN_H) * 3 + mTitleText!.getSize().height)
        mListView = UListView(
            topScene : mTopScene, windowCallbacks : nil, listItemCallbacks : self,
            priority : DRAW_PRIORITY, x : x, y : y,
            width : width - UDpi.toPixel(MARGIN_H) * 2, height : listViewH,
            bgColor: nil)
        
        mListView!.setFrameColor(UIColor.black)
        
        // add items to ListView
        let presetBooks : List<PresetBook> = PresetBookManager.getInstance().getBooks()
        for presetBook in presetBooks {
                let item = ListItemPresetBook(listItemCallbacks: self, book: presetBook, width: mListView!.getClientSize().width)
            mListView!.add(item: item)
        }
        mListView!.updateWindow()
        mListView!.addToDrawManager()
    }

    

    /**
     * ダイアログを表示する
     * @param book
     */
    private func showDialog( book : PresetBook) {

        let width = mTopScene.getWidth()
        // Dialog
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, buttonCallbacks : nil, dialogCallbacks : nil,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : width, screenH : mTopScene.getHeight())
        
        // Title
        mDialog!.setTitle(book.mName)

        // ListView
        let listView = UListView(
            topScene : mTopScene, windowCallbacks : nil, listItemCallbacks : self,
            priority : DRAW_PRIORYTY_DIALOG, x : 0, y : 0,
            width : mDialog!.getSize().width, height : mTopScene.getHeight() - UDpi.toPixel(140), bgColor : UIColor.lightGray,
            topBarH: 0, frameW : 0, frameH : 0)
        mDialog!.addDrawable(obj: listView)

        // Add items to ListView
        for presetCard in book.getCards() {
            let itemCard = ListItemCard(listItemCallbacks: nil, card: presetCard!, width: listView.getClientSize().width)
            listView.add(item: itemCard)
        }
        listView.updateWindow()

        mDialog!.addCloseButton(text: UResourceManager.getStringByName("close"))
        
        mDialog!.addToDrawManager()

    }
    

    private func showMessageDialog() {
        if mMessageDialog == nil {
            mMessageDialog = UDialogWindow.createInstance(
                topScene : mTopScene, type : DialogType.Modal,
                buttonCallbacks : self, dialogCallbacks : self,
                dir : UDialogWindow.ButtonDir.Horizontal, posType : DialogPosType.Center, isAnimation : true,
                screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(),
                textColor : UIColor.black, dialogColor : UIColor.lightGray)
            
            let title = String( format: UResourceManager.getStringByName("confirm_add_book2"), mBook!.mName)
            mMessageDialog!.setTitle(title)
            _ = mMessageDialog!.addButton(
                id : ButtonIdAddOk2, text : "OK", fontSize : UDraw.getFontSize(FontSize.M),
                textColor : UIColor.black, color : UColor.LightGreen)
            
            mMessageDialog!.addToDrawManager()
        }
    }

    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        if mDialog != nil && mDialog!.onBackKeyDown() {
            return true
        }
        if mConfirmDialog != nil && mConfirmDialog!.onBackKeyDown() {
            return true
        }
        if mMessageDialog != nil && mMessageDialog!.onBackKeyDown() {
            return true
        }
        return false
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool {
        switch id {
        case ButtonIdReturn:
            _ = PageViewManagerMain.getInstance().popPage()
            break
        case ButtonIdAddOk:
            // プリセットを追加するかの確認ダイアログでOKボタンを押した
            if (mBook != nil) {
                PresetBookManager.getInstance().addBookToDB( presetBook: mBook!)
            }
            mConfirmDialog!.closeDialog()
            showMessageDialog()
            break
        case ButtonIdAddOk2:
            mMessageDialog!.closeDialog()
            break
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
        // クリックされた項目の学習カード一覧を表示する
        if let book = item as? ListItemPresetBook {
            showDialog(book: book.getBook()!)
        }
    }

    /**
     * 項目のボタンがクリックされた
     * @param item
     * @param buttonId
     */
    public func ListItemButtonClicked( item : UListItem, buttonId : Int) {
        if !(item is ListItemPresetBook) {
            return
        }
        
        switch buttonId {
        case ListItemPresetBook.ButtonIdAdd:
            let book = item as? ListItemPresetBook

            // 追加するかを確認する
            // 終了ボタンを押したら確認用のモーダルダイアログを表示
            if (mConfirmDialog == nil) {
                mConfirmDialog = UDialogWindow.createInstance(
                    topScene : mTopScene, type : DialogType.Modal,
                    buttonCallbacks : self, dialogCallbacks : self,
                    dir : UDialogWindow.ButtonDir.Horizontal, posType : DialogPosType.Center,
                    isAnimation : true,
                    screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(),
                    textColor : UIColor.black, dialogColor : UIColor.lightGray)
                
                let title = String(format: UResourceManager.getStringByName("confirm_add_book"), book!.getBook()!.mName)
                
                mConfirmDialog!.setTitle(title)
                _ = mConfirmDialog!.addButton(id : ButtonIdAddOk, text : "OK", fontSize : UDraw.getFontSize(FontSize.M), textColor : UIColor.black, color : UColor.LightGreen)
            
                mConfirmDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

                // クリックされた項目のBookを記憶しておく
                mBook = book!.getBook()
                
                mConfirmDialog!.addToDrawManager()
            }
            break
        default:
            break
        }
    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed(dialog : UDialogWindow) {
        if dialog === mConfirmDialog {
            mConfirmDialog = nil
        }
        else if dialog === mMessageDialog {
            mMessageDialog = nil
        }
    }
}

