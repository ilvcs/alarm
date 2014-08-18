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
    // Buttons
    @IBOutlet weak var AMPMButton: UISegmentedControl!
    @IBOutlet weak var daySelection: MultiSelectSegmentedControl!
    @IBOutlet weak var selectRingtone: UIButton!
    // Clocks
    @IBOutlet weak var myClock1: BEMAnalogClockView!
    // Text Fields
    @IBOutlet weak var timeEntryField: UITextField!
    @IBOutlet weak var labelField: UITextField!
    // Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    // Other
    let timeRegex = "^(\\d{1,2})(\\d{2})$"
    // var origScrollViewPos = CGPoint(x: 0, y:0)
    //var selectedSong: Int?
    var alarmData: AlarmItem = AlarmItem()
    
    // ---------------------------------------------------------------------------------------------
    // ViewController
    // ---------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        
        // draw toolbar for keypad
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        var emptyPadding = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneWithText")
        toolbar.items = [emptyPadding, doneButton]
        // set toolbar for timeEntryField and set delegates for both fields for "done" button functionality
        timeEntryField.inputAccessoryView = toolbar
        timeEntryField.delegate = self
        labelField.delegate = self
        
        // intialize BEMAnalogClock
        self.initializeClock()
        
        // need this line or scrollView is pushed down
        self.navigationController.navigationBar.translucent = false;

        // scrollView
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(0, 1000)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: "UIKeyboardDidShowNotification", object: nil)
        
        // Select Ringtone Button
        selectRingtone.layer.borderColor = UIColor(red: 25/255.0, green: 134/255.0, blue: 250/255.0, alpha: 1.0).CGColor
        selectRingtone.layer.borderWidth = 1.0
        selectRingtone.layer.cornerRadius = 5;
        
        // Time Entry Text Field
        timeEntryField.borderStyle = UITextBorderStyle.RoundedRect
        
        loadFieldValues()
                
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    // BEMAnalogClock
    // ---------------------------------------------------------------------------------------------
    func initializeClock() {
        var blueTint = UIColor(red: 0.0, green: 122.0/255, blue: 1.0, alpha: 1.0)
        let IBSize = myClock1.bounds.size.height
        
        myClock1.enableShadows = true;
        // myClock1.realTime = true;
        // if set to realTime, when switching from AddAlarm to AlarmList, get a EXC_BAD_ACCESS error 
        // since delegate is gone and doesn't respond to selector I think
        myClock1.currentTime = true;
        myClock1.faceBackgroundColor = UIColor.blackColor()
        myClock1.delegate = self;
        // myClock1.digitFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
        myClock1.digitFont = UIFont(name: "HelveticaNeue-Thin", size: 17)
        myClock1.digitColor = UIColor.whiteColor()
        myClock1.enableDigit = true;
        myClock1.borderColor = UIColor.whiteColor()
        myClock1.borderWidth = 3;
        myClock1.enableGraduations = true
        myClock1.secondHandColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        myClock1.minuteHandLength = IBSize * 0.4
        myClock1.secondHandLength = myClock1.minuteHandLength * 0.75
        myClock1.hourHandLength = myClock1.minuteHandLength * 0.5
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
            
            // after stripping the colon, don't allow more than 4 digits
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
    
    func doneWithText() {
        timeEntryField.resignFirstResponder()
    }
    
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
        return NSString(format: "%d", text.toInt()!)
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
            var ringtonePath = NSBundle.mainBundle().resourcePath
            ringtonePath = ringtonePath.stringByAppendingPathComponent("Ringtones")
            var ringtoneContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(ringtonePath, error: nil)
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
    
    @IBAction func printTextFieldContents(sender: AnyObject) {
        println()
        println("Entered time: \(timeEntryField.text)")
        println("AMPM Button: \(AMPMButton.selectedSegmentIndex)")
        println("Days: \(daySelection.selectedSegmentIndexes)")
        
        var enteredTime = ((timeEntryField.text as NSString).stringByReplacingOccurrencesOfString(":", withString: "") as NSString)
        if enteredTime.length >= 3 {
            var hours = enteredTime.substringToIndex(2)
            var minutes = enteredTime.substringFromIndex(2)
            var totalSeconds = (hours as NSString).integerValue*3600 + (minutes as NSString).integerValue*60
            var date: NSDate! = NSDate(timeIntervalSinceNow: Double(totalSeconds))
            println("Time corresponds to NSDate: \(date)")
        }
        
        if labelField.text == "" {
            println("No label text")
        } else {
            println("Label: \(labelField.text)")
        }
        
        if let s = alarmData.songIndex {
            println("Selected song index: \(s)")
        } else {
            println("No selected song")
        }
        println()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if let id = segue.identifier {
            
            alarmData.AMPMbutton = AMPMButton.selectedSegmentIndex
            
            
            // if users input an invalid time, take the modulo
            var uncheckedTime = timeEntryField.text
            /*uncheckedTime = (uncheckedTime as NSString).stringByReplacingOccurrencesOfString(":", withString: "")
            if uncheckedTime.toInt()!/1000 > 0 {
                uncheckedTime = String(uncheckedTime.toInt()!%1200)
                var matches = regex.matchesInString(uncheckedTime, options: nil, range: NSMakeRange(0, (newText as NSString).length))
                if matches.count == 1 {
                    var match = regex.replacementStringForResult((matches[0] as NSTextCheckingResult), inString: textField.text, offset: 0, template: "$1:$2")
                    textField.text = match
                    return false
                }
            }*/
            alarmData.time = uncheckedTime
            
            alarmData.days = (daySelection.selectedSegmentIndexes as NSMutableIndexSet)
            alarmData.label = labelField.text
            if let s = alarmData.songIndex {
                alarmData.songIndex = s
            } else {
                alarmData.songIndex = 0
            }
            
            if id == "songPicker" {
                var navigationController = segue.destinationViewController as UINavigationController
                var songPickerController = navigationController.topViewController as SongPickerTableViewController
                songPickerController.alarmData = self.alarmData
            } else if id == "doneWithAlarm"{
                var navigationController = segue.destinationViewController as UINavigationController
                var alarmListController = navigationController.topViewController as AlarmListTableViewController
                alarmListController.alarmList.append(alarmData)
                writeToFile(alarmData)
            }
        }
    }
    
    func writeToFile(a: AlarmItem) {
        var file = "test.txt"
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        let directories:[String] = dirs!;
        let dir = directories[0]; //documents directory
        let path = dir.stringByAppendingPathComponent(file);
        
        //println(path)
        
        var text = a.label! + "\n" + a.time! + "\n" + String(a.AMPMbutton!) + "\n"
       
        var index = a.days?.firstIndex
        while index != NSNotFound {
            text += String(index! as Int) + " "
            index = a.days?.indexGreaterThanIndex(index!)
        }
        
        text += "\n" + String(a.songIndex!)

        text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
}
