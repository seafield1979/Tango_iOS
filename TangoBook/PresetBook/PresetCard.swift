//
//  PresetCard.swift
//  TangoBook
//      プリセット単語帳の中のカードクラス
//  Created by Shusuke Unno on 2017/07/31.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public struct PresetCard {
    var mWordA : String
    var mWordB : String
    var mComment  : String? = nil
    
    /**
     * Constructor
     */
    public init(wordA : String, wordB : String, comment : String?) {
        mWordA = wordA
        mWordB = wordB
        mComment = comment
    }
    
    public func log() {
        ULog.printMsg(PresetBookManager.TAG, "wordA:" + mWordA + " wordB:" + mWordB)
    }
}
