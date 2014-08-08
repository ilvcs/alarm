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
    var selected: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        songList = [AnyObject]()
       // songList = NSBundle.mainBundle().pathsForResourcesOfType(".mp3", inDirectory: "Music")
        var musicPath = NSBundle.mainBundle().resourcePath
        musicPath = musicPath.stringByAppendingPathComponent("Music")
        var musicDirContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(musicPath, error: nil)
        songList = musicDirContents
        //print(songList)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
       
        if let row = selected {
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
        selected = indexPath.row
      //  tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var navigationController = segue.destinationViewController as UINavigationController
        var addAlarmController = navigationController.topViewController as AddAlarmViewController
        addAlarmController.selectedSong = selected
    }
    

}
