//
//  SongPickerTableViewController.swift
//  alarm
//
//  Created by Macbook Air on 8/3/14.
//  Copyright (c) 2014 SC. All rights reserved.
//

import UIKit

class SongPickerTableViewController: UITableViewController {
    
    var songList: [AnyObject]!
    var alarmData: AlarmItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        songList = [AnyObject]()
        var ringtonePath = NSBundle.mainBundle().resourcePath
        ringtonePath = ringtonePath.stringByAppendingPathComponent("Ringtones")
        var ringtoneContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(ringtonePath, error: nil)
        songList = ringtoneContents
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return songList.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongPrototypeCell", forIndexPath: indexPath) as UITableViewCell
        var songName = (songList[indexPath.row] as NSString).stringByDeletingPathExtension
        cell.textLabel.text = songName
       
        if let row = alarmData.songIndex {
            if indexPath.row == row {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        alarmData.songIndex = indexPath.row
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        var navigationController = segue.destinationViewController as UINavigationController
        var addAlarmController = navigationController.topViewController as AddAlarmViewController
        addAlarmController.alarmData = self.alarmData
    }
}
