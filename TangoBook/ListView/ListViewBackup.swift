//
//  ListViewBackup.swift
//  TangoBook
//    バックアップページのバックアップファイルを表示するListView
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class ListViewBackup : UListView {
    
    // MARK: Enums
    public enum ListViewType {
        case Backup
        case Restore
    }
    
    // MARK: Constants
    private let LIMIT : Int = 100
    
    // MARK: Properties
    private var mLvType : ListViewType
    
    // MARK: Accessor
    
    // MARK: Initializer
    public init(topScene : TopScene, listItemCallbacks : UListItemCallbacks?, type : ListViewType,
                priority : Int, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, bgColor : UIColor?)
    {
        mLvType = type
        // add items
        let backupFiles : [BackupFile] = BackupFileDao.selectAll()
        
        super.init( topScene : topScene, windowCallbacks : nil,
                    listItemCallbacks : listItemCallbacks, priority : priority,
                    x : x, y : y, width : width, height : height, bgColor : bgColor)
        
        
        for backup in backupFiles {
            let item = ListItemBackup(listItemCallbacks: listItemCallbacks!, backup: backup, x: 0, width: width)
            // バックアップリストでは自動バックアップは表示しない
            // 自動バックアップのスロットに手動でバックアップするのはおかしいので
            if item.getBackup()!.isAutoBackup() && type == ListViewType.Backup {
                continue
            }
            add(item: item)
        }
        
        updateWindow()
    }
    
   
    // MARK: Methods
    
}
