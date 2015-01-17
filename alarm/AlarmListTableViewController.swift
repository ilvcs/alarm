//
//  AlarmListTableViewController.swift
//  alarm
//
//  Created by Macbook Air on 7/25/14.
//  Copyright (c) 2014 SC. All rights reserved.
//

import UIKit

class AlarmListTableViewController: UITableViewController, BEMAnalogClockDelegate {
    
    var alarmList = [AlarmItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // don't show empty cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // populate array of alarms
        var file = "test.txt"
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        let directories:[String] = dirs!;
        let dir = directories[0]; //documents directory
        let path = dir.stringByAppendingPathComponent(file);
        var currentContents: String
        var fileExists = NSFileManager.defaultManager().fileExistsAtPath(path)
        if fileExists == true {
            currentContents = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil) as String
        } else {
            currentContents = ""
        }
        var alarmComponents = currentContents.componentsSeparatedByString("\n")
        //println(alarmComponents)
        var index = 0
        while (index + 2) < alarmComponents.count {
            var alarm1 = AlarmItem()
            alarm1.label = alarmComponents[index]
            alarm1.time = alarmComponents[index+1]
            alarm1.AMPMbutton = alarmComponents[index+2].toInt()!
            
            if alarmComponents[index+3] != "" {
                var days = alarmComponents[index+3].componentsSeparatedByString(" ")
                var set = NSMutableIndexSet()
                for index in days {
                    //println("index is \(index)")
                    set.addIndex(index.toInt()!)
                }
                alarm1.days = set
            }
            
            alarm1.songIndex = alarmComponents[index+4].toInt()!
            alarmList.append(alarm1)
            
            index += 6
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return alarmList.count
    }
    
    @IBAction func unWindToAlarmList(segue: UIStoryboardSegue) {
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlarmPrototypeCell", forIndexPath: indexPath) as UITableViewCell
        
            var alarmData = alarmList[indexPath.row]
            
            if alarmData.label != "" {
                cell.textLabel.text = alarmData.label
            } else {
                cell.textLabel.text = "Unnamed Alarm"
            }
            
            var detailText = ""
            if alarmData.time != "" {
                detailText += alarmData.time!
                if alarmData.AMPMbutton == 0 {
                    detailText += " AM "
                } else {
                    detailText += " PM "
                }
                
                if let x = alarmData.days? {
                    var index = alarmData.days?.firstIndex
                    while index != Foundation.NSNotFound {
                        switch (index! as Int) {
                        case 0:
                            detailText += "Mon "
                        case 1:
                            detailText += "Tue "
                        case 2:
                            detailText += "Wed "
                        case 3:
                            detailText += "Thu "
                        case 4:
                            detailText += "Fri "
                        case 5:
                            detailText += "Sat "
                        case 6:
                            detailText += "Sun "
                        default:
                            detailText += ""
                        }
                        index = alarmData.days?.indexGreaterThanIndex(index!)
                    }
                }
            }
        cell.detailTextLabel.text = detailText
        
        
        var clock = BEMAnalogClockView(frame: CGRectMake(105, 100, 100, 100))
        clock.backgroundColor = view.backgroundColor
        clock.delegate = self
        setupClock(clock)
        var hours: String
        var minutes: String
        if String(Array(alarmData.time!)[2]) == ":" {
            hours = String(Array(alarmData.time!)[0]) + String(Array(alarmData.time!)[1])
            minutes = String(Array(alarmData.time!)[3]) + String(Array(alarmData.time!)[4])
        } else {
            hours = String(Array(alarmData.time!)[0])
            minutes = String(Array(alarmData.time!)[2]) + String(Array(alarmData.time!)[3])
        }
        clock.hours = hours.toInt()!
        clock.minutes = minutes.toInt()!
        
        var img = imageFromView(clock)
        cell.imageView.image = img
        
        return cell
    }
    
    func imageFromView(view: BEMAnalogClockView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        var ctx = UIGraphicsGetCurrentContext()
        
//        CGContextConcatCTM(ctx, CGAffineTransformMakeRotation((30.0 as CGFloat)*(3.1415/180)))
        view.layer.renderInContext(ctx)
        var img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func setupClock(myClock1: BEMAnalogClockView) {
        let clockSize = myClock1.bounds.size.height
        myClock1.enableShadows = true;
        myClock1.faceBackgroundColor = UIColor.blackColor()
        myClock1.borderColor = UIColor.whiteColor()
        myClock1.borderWidth = 3;
        myClock1.enableGraduations = true
        myClock1.secondHandColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        myClock1.minuteHandLength = clockSize * 0.3
        myClock1.secondHandLength = myClock1.minuteHandLength * 0.75
        myClock1.hourHandLength = myClock1.minuteHandLength * 0.5
        myClock1.minuteHandOffsideLength = myClock1.minuteHandLength/4
        myClock1.hourHandOffsideLength = myClock1.hourHandLength/4

    }

    func analogClock(clock: BEMAnalogClockView!, graduationLengthForIndex index: Int) -> CGFloat {
        if (index % 5 == 0){
            return 20; // The length of one graduation in every five graduation will be 20.
        } else {
            return 5; // The length of the rest of the graduations will be 5.
        }
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationColorForIndex index: Int) -> UIColor! {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        
            
        
        
        
        
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
}
