//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewRestore : UPageView, UDialogCallbacks, UButtonCallbacks, UListItemCallbacks
{
    // MARK: Constants
    private let DRAW_PRIORITY = 1

    // layout
    private let TOP_Y : Int = 17
    private let MARGIN_H : Int = 17
    private let MARGIN_V : Int = 17
    private let FONT_SIZE_S : Int = 15
    private let FONT_SIZE : Int = 17

    private let FONT_COLOR = UIColor.black

    // button Ids
//    private let ButtonIdRestoreFromFile = 100     // 選択したファイルから復元ボタンを押した
//    private let ButtonIdRestoreFromFileOK = 101   // 選択したファイルから復元するかどうかでOKを選択
    private let ButtonIdRestoreOK1 = 102          // 復元確認1でOKを選択
    private let ButtonIdRestoreOK2 = 103          // 復元確認2でOKを選択
    private let ButtonIdNotFoundOK = 104          // バックアップファイルが見つからなかった

    // MARK: Properties
    private var mListView : ListViewBackup?
    private var mBackupItem : ListItemBackup?     // リストで選択したアイテム

    // Dialog
    private var mDialog : UDialogWindow?
    private var mRestoreFileURL : URL?          // 復元元のバックアップファイルのURL

    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

        let x = UDpi.toPixel(MARGIN_H)
        let y = UDpi.toPixel(TOP_Y)

        UDrawManager.getInstance().initialize()

        // ListView
        let listViewH = height - (y + UDpi.toPixel(MARGIN_V))
        mListView = ListViewBackup(
            topScene : mTopScene, listItemCallbacks : self,
            type : ListViewBackup.ListViewType.Restore, priority : DRAW_PRIORITY,
            x : x, y : y, width : width - UDpi.toPixel(MARGIN_H) * 2, height : listViewH,
            bgColor : nil)
        
        mListView!.setFrameColor(UIColor.gray)
        mListView!.addToDrawManager()
    }
    

    /**
     * 復元確認ダイアログを表示する（２回目の確認用)
     */
    private func confirmRestore() {
        if mDialog != nil {
            mDialog!.closeDialog()
        }

        // Dialog
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight() )
        
        // 復元確認ダイアログの表示
        mDialog!.setTitle( UResourceManager.getStringByName("confirm_restore2"))
        mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
        _ = mDialog!.addButton(id: ButtonIdRestoreOK2, text: "OK", fontSize: UDpi.toPixel(FONT_SIZE), textColor: UIColor.black, color: UIColor.white)
        
        mDialog!.addToDrawManager()
    }
    /**
     * 復元を行う
     * @return 結果(成功/失敗)
     */
    private func doRestore(url : URL) -> Bool{
        let ret = BackupManager.getInstance().loadBackup(url : url)

        let title = UResourceManager.getStringByName( ret ? "succeed_restore" : "failed_restore")

        // ダイアログを表示
        if mDialog != nil {
            mDialog!.closeDialog()
        }
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight())
        
        mDialog!.setTitle(title)
        mDialog!.addCloseButton(text: "OK", textColor: UIColor.black, bgColor: UIColor.white)
        
        mDialog!.addToDrawManager()
        
        return ret
    }

    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch id {
//        case ButtonIdRestoreFromFile:
//            getFilePath();
//        
//        case ButtonIdRestoreFromFileOK:
//            doRestore(mRestoreFile)
            
        case ButtonIdRestoreOK1:
            confirmRestore()
            
        case ButtonIdRestoreOK2:
            _ = doRestore(url: mRestoreFileURL!)
            
        case ButtonIdNotFoundOK:
            mDialog!.closeDialog()
            // バックアップ情報を削除する
            _ = BackupFileDao.clearOne( id: mBackupItem!.getBackup()!.getId() )
            mBackupItem!.setText( text: UResourceManager.getStringByName("empty") )
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
        let width = mTopScene.getWidth()

        // リストの種類を判定
        if !(item is ListItemBackup) {
            return
        }

        let backupItem = item as? ListItemBackup

        let backup : BackupFile? = backupItem!.getBackup()
        if backup == nil {
            return
        }
        
        if backup!.isEnabled() {
            // show confirmation dialog 1
            mBackupItem = backupItem!

            let url : URL = BackupManager.getManualBackupURL(slot: backup!.id)
            mRestoreFileURL = url
            
            // バックアップファイルの有無を確認（手動で消されていることもありえる）
            var isDir : ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path,
                                              isDirectory: &isDir) == false
            {
                // ファイルが見つからなかったので復元不可能
                mDialog = UDialogWindow.createInstance(
                    topScene : mTopScene, buttonCallbacks : self,
                    dialogCallbacks : self, buttonDir : UDialogWindow.ButtonDir.Horizontal,
                    screenW : width, screenH : mTopScene.getHeight())
                
                mDialog!.setTitle(UResourceManager.getStringByName("backup_not_found"))
                _ = mDialog!.addButton(id: ButtonIdNotFoundOK, text: "OK", fontSize: UDpi.toPixel(FONT_SIZE), textColor: UIColor.black, color: UIColor.white)
                
                mDialog!.addToDrawManager()
            } else {
                // ファイルがあるので復元確認ダイアログを表示する
                mDialog = UDialogWindow.createInstance(
                    topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
                    buttonDir : UDialogWindow.ButtonDir.Horizontal,
                    screenW : width, screenH : mTopScene.getHeight())
                mDialog!.setTitle(UResourceManager.getStringByName("confirm_restore"))
                _ = mDialog!.addButton(id: ButtonIdRestoreOK1, text: "OK", fontSize: UDpi.toPixel(FONT_SIZE), textColor: UIColor.black, color: UIColor.white)
                mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
                
                mDialog!.addToDrawManager()
            }
        }
    }
    /**
     * 項目のボタンがクリックされた
     */
    public func ListItemButtonClicked(item : UListItem, buttonId : Int){

    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed( dialog : UDialogWindow) {
        if mDialog === dialog {
            mDialog = nil
        }
    }

    
    /**
     * Constructor
     */
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.RestoreDB.rawValue, title: title)
    }
    
    // MARK: Methods
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
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
}
