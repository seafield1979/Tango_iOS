//
//  ListViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

/**
 * Created by shutaro on 2017/06/16.
 */

//public class ListViewBackup extends UListView {
//    /**
//     * Enums
//     */
//    public enum ListViewType{
//        Backup,
//        Restore
//    }
//    
//    /**
//     * Constants
//     */
//    
//    private static final int LIMIT = 100;
//    /**
//     * Member variables
//     */
//    private ListViewType mLvType;
//    
//    /**
//     * Get/Set
//     */
//    
//    /**
//     * Constructor
//     */
//    public ListViewBackup(UListItemCallbacks listItemCallbacks, ListViewType type,
//    int priority, float x, float y, int width, int
//    height, int color)
//    {
//        super(null, listItemCallbacks, priority, x, y, width, height, color);
//        
//        mLvType = type;
//        // add items
//        List<BackupFile> backupFiles = RealmManager.getBackupFileDao().selectAll();
//        
//        for (BackupFile backup : backupFiles) {
//            ListItemBackup item = new ListItemBackup(listItemCallbacks, backup, 0, width);
//            // バックアップリストでは自動バックアップは表示しない
//            // 自動バックアップのスロットに手動でバックアップするのはおかしいので
//            if (item.getBackup().isAutoBackup() && type == ListViewType.Backup) {
//                continue;
//            }
//            if (item != null) {
//                add(item);
//            }
//        }
//        
//        updateWindow();
//    }
//    
//    /**
//     * Methods
//     */
//    
//    
//    /**
//     * for Debug
//     */
//    public void addDummyItems(int count) {
//        
//        updateWindow();
//    }
//    
//    /**
//     * Callbacks
//     */
//    
//}
