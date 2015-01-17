//
//  AddAlarmViewController.swift
//  alarm
//
//  Created by Macbook Air on 7/25/14.
//  Copyright (c) 2014 SC. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, BEMAnalogClockDelegate {
    
    // ---------------------------------------------------------------------------------------------
    // Member Variables
    // ---------------------------------------------------------------------------------------------
    @IBOutlet weak var AMPMButton: UISegmentedControl!
    @IBOutlet weak var daySelection: MultiSelectSegmentedControl!
    @IBOutlet weak var selectRingtone: UIButton!
    @IBOutlet weak var timeEntryField: UITextField!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    let timeRegex = "^(\\d{1,2})(\\d{2})$"
    var alarmData: AlarmItem = AlarmItem()
    
    // ---------------------------------------------------------------------------------------------
    // ViewController
    // ---------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        
        // set toolbar for timeEntryField and set delegates for both fields for "done" button functionality
        setupTimeEntryField()
        labelField.delegate = self
        
        // need this line or scrollView is pushed down
        self.navigationController.navigationBar.translucent = false;

        // scrollView
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(0, 1000)
        
        setupSelectRingtoneButton()
        loadFieldValues()
                
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupToolbar()-> UIToolbar{
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        var emptyPadding = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithText")
        toolbar.items = [emptyPadding, doneButton]
        return toolbar
    }
    
    /**Set up the border style, toolbar, and delegate for the Time Entry field*/
    func setupTimeEntryField() {
        timeEntryField.borderStyle = UITextBorderStyle.RoundedRect
        timeEntryField.inputAccessoryView = setupToolbar()
        timeEntryField.delegate = self
    }
    
    /**Set up the border color, width, and corner radius for the Select Ringtone button*/
    func setupSelectRingtoneButton() {
        selectRingtone.layer.borderColor = UIColor(red: 25/255.0, green: 134/255.0, blue: 250/255.0, alpha: 1.0).CGColor
        selectRingtone.layer.borderWidth = 1.0
        selectRingtone.layer.cornerRadius = 5;
    }
    
    /**Called when switching between the AddAlarmView and SongPickerTableView to reload previously entered
        user values*/
    func loadFieldValues() {
        if let t = alarmData.time {
            self.timeEntryField.text = t
        }
        if let ampm = alarmData.AMPMbutton {
            self.AMPMButton.selectedSegmentIndex = ampm
        }
        if let d = alarmData.days{
            self.daySelection.selectedSegmentIndexes = alarmData.days
        }
        if let l = alarmData.label {
            self.labelField.text = l
        }
    }
    
    // ---------------------------------------------------------------------------------------------
    // textField
    // ---------------------------------------------------------------------------------------------

    func textFieldDidBeginEditing(textField: UITextField!) {
        scrollView.setContentOffset(CGPointMake(0, textField.center.y-50), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        
        if textField == timeEntryField {
            var newText = ((textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string))
            newText = removeColonFromString(newText)
            newText = removeLeadingZeroesFromString(newText)
            
            // after stripping the colon and leading zeroes, don't allow more than 4 digits
            if (newText as NSString).length > 4 {
                var alert = UIAlertView(title: "Error", message: "You may only add up to 4 numbers", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                textField.resignFirstResponder()
                return false
            }
            
            textField.text = addColonToString(newText)
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**Resign first responder (called by the toolbar Done button)*/
    func doneWithText() {
        timeEntryField.resignFirstResponder()
    }
    
    /**Given a string of 1 to 4 ints, convert into conventional time format
    :param: text
    :returns: */
    func addColonToString(text: String) -> String {
        if (text as NSString).length == 1 {
            return "00:0" + text
        } else if (text as NSString).length == 2 {
            return "00:" + text
        } else if (text as NSString).length > 4 {
            return text
        }
        
        var oldTextRange = NSMakeRange(0, (text as NSString).length)
        var regex = NSRegularExpression(pattern: timeRegex, options: nil, error: nil)
        var matches = regex.matchesInString(text, options: nil, range: oldTextRange)
        var match = regex.replacementStringForResult((matches[0] as NSTextCheckingResult), inString: text, offset: 0, template: "$1:$2")
        return match
    }
    
    func removeColonFromString(text:String) -> String {
        return (text as NSString).stringByReplacingOccurrencesOfString(":", withString: "")
    }
    
    func removeLeadingZeroesFromString(text: String) -> String {
        if (text as NSString).length > 0 {
            return NSString(format: "%d", text.toInt()!)
        }
        
        return text
    }
    
    // ---------------------------------------------------------------------------------------------
    // Actions
    // ---------------------------------------------------------------------------------------------

    @IBAction func doShit(sender: UIBarButtonItem) {
        var futureDate: NSDate?
        futureDate = NSDate(timeIntervalSinceNow: 5)
        var notification: UILocalNotification = UILocalNotification()
        // notification.repeatInterval = NSCalendarUnit.CalendarUnitWeekdayOrdinal
        
        if let s = alarmData.songIndex {
            var songList = [AnyObject]()
            var ringtonePath = NSBundle.mainBundle().resourcePath!
            ringtonePath = ringtonePath.stringByAppendingPathComponent("Ringtones")
            var ringtoneContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(ringtonePath, error: nil)!
            var selectedSongPath = "Ringtones/" + (ringtoneContents[s] as String)
            notification.soundName = selectedSongPath
        } else {
            notification.soundName = "Ringtones/Election Theme.m4r"
        }
        
        notification.fireDate = futureDate
        notification.alertAction = "OK"
        
        if let l = alarmData.label {
            notification.alertBody = "This is an alarm for \(l)"
        }
        else {
            notification.alertBody = "This is a generic alarm."
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if let id = segue.identifier {
            
            packageAlarmData()
            if id == "songPicker" {
                var navigationController = segue.destinationViewController as UINavigationController
                var songPickerController = navigationController.topViewController as SongPickerTableViewController
                songPickerController.alarmData = self.alarmData
            } else if id == "doneWithAlarm"{
                var navigationController = segue.destinationViewController as UINavigationController
                var alarmListController = navigationController.topViewController as AlarmListTableViewController
                writeToFile(alarmData)
            }
        }
    }
    
    // take the user's input and set alarmData's values
    func packageAlarmData() {
        alarmData.AMPMbutton = AMPMButton.selectedSegmentIndex
        
        if timeEntryField.text != "" {
            // if user inputs hours > 12, take the modulo
            var uncheckedTime = removeColonFromString(timeEntryField.text)
            uncheckedTime = removeLeadingZeroesFromString(uncheckedTime)
            if uncheckedTime.toInt()!/1000 > 0 {
                uncheckedTime = String(uncheckedTime.toInt()!%1200)
            }
            // if entered 2 or more numbers, make sure tens place is not > 5
            switch uncheckedTime.utf16Count {
            case 2:
                uncheckedTime = String(uncheckedTime.toInt()!%60)
            case 3:
                var minutes = (uncheckedTime.toInt()!%100)%60
                uncheckedTime = String(Array(uncheckedTime)[0])
                if minutes < 10 {
                    uncheckedTime += "0" + String(minutes)
                } else {
                    uncheckedTime += String(minutes)
                }
            case 4:
                uncheckedTime = String(seq: Array(uncheckedTime)[0...1]) + String((uncheckedTime.toInt()!%100)%60)
            default:
                break
            }
            // if user entered 1 or 2 characters, assume the hour to be 12
            if uncheckedTime.toInt()!/10 == 0 {
                uncheckedTime = "12:0" + uncheckedTime
            } else if uncheckedTime.toInt()!/100 == 0 {
                uncheckedTime = "12:" + uncheckedTime
            } else {
                uncheckedTime = addColonToString(uncheckedTime)
            }
            alarmData.time = uncheckedTime
        }
        else {
            alarmData.time = "12:00"
        }
        
        alarmData.days = (daySelection.selectedSegmentIndexes as NSMutableIndexSet)
        alarmData.label = labelField.text
        if let s = alarmData.songIndex {
            alarmData.songIndex = s
        } else {
            alarmData.songIndex = 0
        }
    }
    
    func writeToFile(a: AlarmItem) {
        var file = "test.txt"
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        let directories:[String] = dirs!;
        let dir = directories[0]; //documents directory
        let path = dir.stringByAppendingPathComponent(file);
        println(path)
        var currentContents: String
        var fileExists = NSFileManager.defaultManager().fileExistsAtPath(path)
        if fileExists == true {
            currentContents = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil) as String
        } else {
            currentContents = ""
        }
        
        var text = a.label! + "\n" + a.time! + "\n" + String(a.AMPMbutton!) + "\n"
        var stringOfDays = ""
        if let x = a.days? {
            var index = a.days?.firstIndex
            while index != Foundation.NSNotFound {
                stringOfDays += String(index! as Int) + " "
                index = a.days?.indexGreaterThanIndex(index!)
            }
            if stringOfDays != "" {
                stringOfDays = stringOfDays.substringToIndex(stringOfDays.endIndex.predecessor())
            }
        }
        text += stringOfDays + "\n"
        text = text.substringToIndex(text.endIndex.predecessor()) // remove unneeded space for day of week array
        text += "\n" + String(a.songIndex!) + "\n" + "\n"
        
        currentContents += text
        currentContents.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
}
