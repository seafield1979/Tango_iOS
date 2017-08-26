//
//  PageViewBackup.swift
//  TangoBook
//      PageViewStudy~系クラスの親クラス
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewStudy : UPageView, UButtonCallbacks, UDialogCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewStudy"
    /**
      * Constants
      */
    public static let ButtonIdExit = 200
    public static let ButtonIdExitOk = 201

    /**
     * Member variables
     */
    // 終了確認ダイアログ
    var mConfirmDialog : UDialogWindow?
    var isCloseOk : Bool = false

    // 学習する単語帳 or カードリスト
    public var mBook : TangoBook?
    public var mCards : List<TangoCard>?
    
    /**
     * Get/Set
     */
    public func setBook( _ book : TangoBook? ) {
        mBook = book
    }
    
    public func setCards( _ cards : List<TangoCard>? ) {
        mCards = cards
    }

    /**
     * Constructor
     */
    public override init( topScene : TopScene, pageId: Int, title : String) {
        super.init( topScene: topScene, pageId: pageId, title: title)
    }
    
    /**
      * ページ終了確認ダイアログを表示する
      */
    private func showExitConfirm() {
        if mConfirmDialog == nil {
            isCloseOk = false

            mConfirmDialog = UDialogWindow.createInstance(
                topScene: mTopScene,
                type: .Modal,
                buttonCallbacks: self, dialogCallbacks: self,
                dir: UDialogWindow.ButtonDir.Horizontal,
                posType: .Center,
                isAnimation: true, x: 0, y: 0,
                screenW: mTopScene.getWidth(), screenH: mTopScene.getHeight(),
                textColor: .black, dialogColor: .lightGray)
            
            mConfirmDialog!.setTitle( UResourceManager.getStringByName("confirm_exit"))
            mConfirmDialog!.addButton(id: PageViewStudy.ButtonIdExitOk, text: "OK", fontSize: UDraw.getFontSize(FontSize.M), textColor: .black, color: .white)
            
            mConfirmDialog!.addCloseButton( text: UResourceManager.getStringByName(
                "cancel"))
            
            mConfirmDialog!.updateLayout()
            mConfirmDialog!.addToDrawManager()
        }
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
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()
        

        
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        showExitConfirm()
        return true
    }
    
    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch(id) {
        case PageViewStudy.ButtonIdExit:
            // 終了ボタンを押したら確認用のモーダルダイアログを表示
            showExitConfirm();
            
        case PageViewStudy.ButtonIdExitOk:
            // 終了
            isCloseOk = true
            mConfirmDialog!.closeDialog()
        default:
            break
        }
        return false
    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed( dialog : UDialogWindow ) {
        if isCloseOk {
            // 終了して前のページに戻る
            _ = PageViewManagerMain.getInstance().popPage()
        }
        if dialog === mConfirmDialog {
            mConfirmDialog = nil
        }
    }
}
