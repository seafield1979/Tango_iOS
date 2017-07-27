//
//  TangoEnums.swift
//  TangoBook
//    単語帳アプリのEnum
//  Created by Shusuke Unno on 2017/07/27.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

// 学習タイプ
// 英語から日本語、日本語から英語
public enum StudyType : Int, EnumEnumerable {
    case EtoJ = 0
    case JtoE
    
    public func getString() -> String {
        var strName : String
        if self == StudyType.EtoJ {
            strName = "study_type_1"
        } else {
            strName = "study_type_2"
        }
        
        return UResourceManager.getStringByName(strName)
    }
}

// 学習モード
public enum StudyMode : Int, EnumEnumerable {
    case SlideOne = 0
    case SlideMulti
    case Choice4
    case Input

    public func getString() -> String {
        var strName : String
        switch self {
        case .SlideOne:
            strName = "study_mode_1"
        case .SlideMulti:
            strName = "study_mode_2"
        case .Choice4:
            strName = "study_mode_3"
        case .Input:
            strName = "study_mode_4"
        }
        
        return UResourceManager.getStringByName(strName)
    }
}

/**
 * Created by shutaro on 2017/06/14.
 * 並び順
 */
public enum StudyOrder : Int, EnumEnumerable {
    case Normal = 0
    case Random
    
    public func getString() -> String {
        var strName : String
        if self == StudyOrder.Normal {
            strName = "study_order_1"
        } else {
            strName = "study_order_2"
        }
        
        return UResourceManager.getStringByName(strName)
    }
}


/**
 * 出題絞り込み
 */
public enum StudyFilter : Int, EnumEnumerable {
    case All = 0
    case NotLearned
        
    public func getString() -> String {
        var strName : String
        if self == StudyFilter.All {
            strName = "study_filter_1"
        } else {
            strName = "study_filter_2"
        }
        
        return UResourceManager.getStringByName(strName)
    }
}
