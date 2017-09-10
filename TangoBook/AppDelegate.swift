//
//  AppDelegate.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        window = UIWindow(frame:UIScreen.main.bounds)
        let viewController = GameViewController(nibName: "GameViewController", bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        
        initSystem()
        UUtil.initialize(navigationC: navigationController)
        
        return true
    }
    
    /**
     システムを初期化する。ユーザー独自の初期化処理を行う
     */
    func initSystem() {
        
        NanoTimer.initialize()
        ULog.initialize()
        
        // データベース(Realm)初期化
        let realm = try! Realm()
        URealmManager.setRealm(realm)
        TangoCardDao.setRealm(realm)
        TangoBookDao.setRealm(realm)
        TangoBookHistoryDao.setRealm(realm)
        TangoItemPosDao.setRealm(realm)
        TangoStudiedCardDao.setRealm(realm)
        BackupFileDao.setRealm(realm)
        BackupManager.setRealm(realm)
        
        // 初回起動時の準備

        // アプリ初期化処理
        if (MySharedPref.readBool(MySharedPref.InitializeKey) == false) {
            // セーブデータを初期化
            BackupFileDao.createInitialRecords()
            
            // デフォルト単語帳を追加
            PresetBookManager.getInstance().addDefaultBooks()
            
            MySharedPref.writeBool(key: MySharedPref.InitializeKey, value: true)
            
            // 拡大率（iPadなら少し大きめ)
            var scale : UDpi.Scale
            if UIDevice.current.userInterfaceIdiom == .pad {
                scale = UDpi.Scale.S150
            } else {
                scale = UDpi.Scale.S100
            }
            MySharedPref.writeInt(key: MySharedPref.ScaleKey, value: scale.rawValue)
        }
        
        // 起動時の自動バックアップ
        if (MySharedPref.readBool(MySharedPref.AutoBackup)) {
            _ = BackupManager.getInstance().saveAutoBackup()
        }
    }
}

