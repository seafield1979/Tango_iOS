//
//  UViewEnum.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation

/**
 * Created by shutaro on 2017/06/14.
 * doActionメソッドをの戻り値
 */
public enum DoActionRet {
    case None                // 何も処理しない
    case Redraw              // 再描画あり(doActionループ処理を継続)
    case Done                // 完了(doActionループ終了)
}
