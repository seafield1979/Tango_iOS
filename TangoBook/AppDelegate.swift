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
        let viewController = ViewController(nibName: "ViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        
        initSystem()
        
        return true
    }
    
    /**
     システムを初期化する。ユーザー独自の初期化処理を行う
     */
    func initSystem() {
        let realm = try! Realm()
        
        TangoCardDao.setRealm(realm)
        TangoCardHistoryDao.setRealm(realm)
        TangoBookDao.setRealm(realm)
        TangoBookHistoryDao.setRealm(realm)
        TangoItemPosDao.setRealm(realm)
        TangoStudiedCardDao.setRealm(realm)
    }
}

