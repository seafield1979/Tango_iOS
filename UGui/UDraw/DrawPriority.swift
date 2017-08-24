//
//  DrawPriority.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/14.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation


/**
 * 描画優先度
 * 値が大きい方が手前に描画される
 */
public enum DrawPriority : Int {
    case Dialog = 100
    case PreStudyWindow = 30
    case SubWindowIcon = 20
    case DragIcon = 11
    case IconWindow = 5
    ;
}
