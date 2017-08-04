//
//  URealmManager.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/04.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import RealmSwift

/**
 * Realmの共通処理
 */

public class URealmManager {
    public static let TAG = "URealmManager"
    
    public static var mRealm : Realm?
    
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }
    public static func getRealm() -> Realm?{
        return mRealm
    }
}

