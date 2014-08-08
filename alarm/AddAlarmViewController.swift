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
    var origScrollViewPos = CGPoint(x: 0, y:0)
    var selectedSong: Int?
    
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
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    func keyboardDidShow(note: NSNotification) {
//        var offset = labelField.center
//        offset.y -= 50
//        scrollView.center = offset
//    }
    
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
//        if textField == labelField {
//            origScrollViewPos = scrollView.center
//            var newScrollViewPos = textField.center
//            newScrollViewPos.y -= 50
//            scrollView.center = newScrollViewPos
//        }
        scrollView.setContentOffset(CGPointMake(0, textField.center.y-50), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
//        if textField == labelField {
//            scrollView.center = origScrollViewPos
//        }
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)

    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        
        if textField == timeEntryField {
            var newText = ((textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string))
            newText = (newText as NSString).stringByReplacingOccurrencesOfString(":", withString: "")
            var oldTextRange = NSMakeRange(0, (newText as NSString).length)
            var regex = NSRegularExpression(pattern: timeRegex, options: nil, error: nil)
            var matches = regex.matchesInString(newText, options: nil, range: oldTextRange)
            
            // after stripping the colon, don't allow more than 4 digits
            if (newText as NSString).length > 4 {
                var alert = UIAlertView(title: "Error", message: "You may only add up to 4 numbers", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                textField.resignFirstResponder()
                return false
            }

            // if we matched either 3 or 4 digits, add a colon
            if matches.count == 1 {
                textField.text = newText
                var match = regex.replacementStringForResult((matches[0] as NSTextCheckingResult), inString: textField.text, offset: 0, template: "$1:$2")
                textField.text = match
                return false
            }
            // else didn't match enough digits, remove previous colons if any
            else {
                if (newText as NSString).length < 3 {
                    textField.text = newText
                    return false
                }
            }
            
            return true
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
    
    // ---------------------------------------------------------------------------------------------
    // Actions
    // ---------------------------------------------------------------------------------------------

    
    @IBAction func alert() {
        var alert:UIAlertView = UIAlertView(title: "Shitnigga", message: "THis is an alert", delegate: self, cancelButtonTitle: "dont do it bitch")
        alert.addButtonWithTitle("fuck you he did it")
        alert.show()
    }
    
    @IBAction func doShit(sender: UIBarButtonItem) {
        var futureDate: NSDate?
        futureDate = NSDate(timeIntervalSinceNow: 5)
        var notification: UILocalNotification = UILocalNotification()
        // notification.repeatInterval = NSCalendarUnit.CalendarUnitWeekdayOrdinal
        notification.soundName = "Music/Election Theme.m4r"
        notification.fireDate = futureDate
        notification.alertAction = "OK"
        notification.alertBody = "This is an ALERT"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    @IBAction func printTextFieldContents(sender: AnyObject) {
        println("Entered time: \(timeEntryField.text)")
        println("AMPM Button: \(AMPMButton.selectedSegmentIndex)")
        println("Days: \(daySelection.selectedSegmentIndexes)")
        var enteredTime = ((timeEntryField.text as NSString).stringByReplacingOccurrencesOfString(":", withString: "") as NSString)
        if enteredTime.length >= 3 {
            var hours = enteredTime.substringToIndex(2)
            var minutes = enteredTime.substringFromIndex(2)
            var totalSeconds = (hours as NSString).integerValue*3600 + (minutes as NSString).integerValue*60
            var date: NSDate! = NSDate(timeIntervalSinceNow: Double(totalSeconds))
            println(date)
        }
        println("Label: \(labelField.text)")
        
        if let s = selectedSong {
            println("Selected song index: \(s)")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if let identifer = segue.identifier {
            if identifer == "songPicker" {
                if let s = selectedSong {
                    var navigationController = segue.destinationViewController as UINavigationController
                    var songPickerController = navigationController.topViewController as SongPickerTableViewController
                    songPickerController.selected = s
                }
            }
        }
    }
}
