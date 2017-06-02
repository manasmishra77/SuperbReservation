//
//  ReservationViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 14/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//


import UIKit
import BEMCheckBox
import DropDown

class ReservationViewController: UIViewController, BEMCheckBoxDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var vipCheckBox: BEMCheckBox!
    @IBOutlet weak var guestPhoneNumber: UITextField!
    @IBOutlet weak var guestPhoto: UIImageView!
    @IBOutlet weak var guestName: UITextField!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var mailId: UITextField!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var bookingStatusDropDown: UIButton!
    @IBOutlet weak var peopleDropDown: UIButton!
    @IBOutlet weak var numberOfTable: UIButton!
    @IBOutlet weak var timeingDropDown: UIButton!
    @IBOutlet weak var durationDropDown: UIButton!
    @IBOutlet weak var bookingType: UIButton!
    @IBOutlet weak var emailConfirmation: BEMCheckBox!
    @IBOutlet weak var smsConfirmation: BEMCheckBox!
    @IBOutlet weak var manualPayment: BEMCheckBox!
    
    
    var bookingData: ReservationInfo?
    var availableTimesArray = [String:Date]()
    var bookingTypeArray = [String]()
    var tablesArray = [String : String]()
    var groupCheckBox: BEMCheckBoxGroup?
    
    let bookingStatusDropDownVar = DropDown()
    let peopleDropDownVar = DropDown()
    let numberOfTableVar = DropDown()
    let timeingDropDownVar = DropDown()
    let durationDropDownVar = DropDown()
    let bookingTypeVar = DropDown()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        initialSetting()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Initial Setting or on edit button
    func initialSetting(){
        contentViewHeight.constant = self.view.frame.height + 150
        vipCheckBox.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        emailConfirmation.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        smsConfirmation.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        manualPayment.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        vipCheckBox.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        emailConfirmation.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        smsConfirmation.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        manualPayment.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        
        peopleDropDownVar.anchorView = peopleDropDown
        bookingStatusDropDownVar.anchorView = bookingStatusDropDown
        numberOfTableVar.anchorView = numberOfTable
        timeingDropDownVar.anchorView = timeingDropDown
        durationDropDownVar.anchorView = durationDropDown
        bookingTypeVar.anchorView = bookingType
        peopleDropDownVar.bottomOffset = CGPoint(x: 0, y: 0)
        
        
        var _: [DropDown] = {
            return [self.bookingStatusDropDownVar, self.peopleDropDownVar,self.numberOfTableVar, self.timeingDropDownVar,self.durationDropDownVar, self.bookingTypeVar]
        }() 
        
        bookingStatusDropDownVar.dataSource = ["cancel", "no-show", "completed", "confirmed", "hold", "new", "left-message", "partially-arrived", "arrived", "partially-seated", "seated"]
        peopleDropDownVar.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "32", "32", "33", "34", "35", "36"]
        durationDropDownVar.dataSource = ["15 min", "30 min", "45 min", "60 min", "90 min", "120 min", "150 min", "180 min", "210 min", "240 min", "270 min", "300 min"]
        if bookingData == nil{
            getTimes()
        }
        getBookingTypes()
        getAvailableTables()
        vipCheckBox.delegate = self
        vipCheckBox.on = false
        groupCheckBox = BEMCheckBoxGroup.init(checkBoxes: [emailConfirmation, smsConfirmation, manualPayment])
        groupCheckBox?.selectedCheckBox = smsConfirmation
        groupCheckBox?.mustHaveSelection = true
        emailConfirmation.delegate = self
        smsConfirmation.delegate = self
        manualPayment.delegate = self
        guestName.delegate = self
        guestPhoneNumber.delegate = self
        mailId.delegate = self
        notes.delegate = self
        if bookingData != nil{
            contentView.isUserInteractionEnabled = true
            navigationTitle.title = "Edit Reservation"
            guestPhoneNumber.text = bookingData?.user.mobile
            bookingStatusDropDown.setTitle(bookingData?.status, for: .normal)
            peopleDropDown.setTitle(String(describing: (bookingData?.guests)!), for: .normal)
            durationDropDown.setTitle("\(String(describing: (bookingData?.duration)!)) min", for: .normal)
            
            if bookingData?.arrivalTime != ""{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                dateFormatter.timeZone = SessionManager.current.selectedRestaurant.timeZone
                let dateToBeDisplayedInUTC = dateFormatter.date(from: (bookingData?.arrivalTime)!)
                dateFormatter.dateFormat = "HH:mm"
                //dateFormatter.timeZone = TimeZone.current
                let dateString = dateFormatter.string(from: dateToBeDisplayedInUTC!)
                timeingDropDown.setTitle(dateString, for: .normal)
            }
            let url = bookingData?.user.photoUrl
            guestPhoto.adoptCircularShape()
            guestPhoto.downloadedFrom(link: url!, contentMode: .scaleAspectFit)
            guestName.text = "\(String(describing: (bookingData?.user.name["first"]!)!)) \(String(describing: (bookingData?.user.name["last"]!)!))"
            mailId.text = bookingData?.user.email
            notes.text = bookingData?.notes
            if (bookingData?.user.vip)!{
                    self.vipCheckBox.on = true
            }
            
        }
        bookingStatusDropDownVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.bookingStatusDropDown.setTitle(item, for: .normal)
        }
        peopleDropDownVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.peopleDropDown.setTitle(item, for: .normal)
        }
        numberOfTableVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.numberOfTable.setTitle(item, for: .normal)
        }
        timeingDropDownVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.timeingDropDown.setTitle(item, for: .normal)
        }
        durationDropDownVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.durationDropDown.setTitle(item, for: .normal)
        }
        bookingTypeVar.selectionAction = { [unowned self] (index: Int, item: String) in
            self.bookingType.setTitle(item, for: .normal)
        }
        
    }
    func didTap(_ checkBox: BEMCheckBox) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onDone(_ sender: Any) {
        contentView.isUserInteractionEnabled = false
        var parameter = [String: Any?]()
        if timeingDropDownVar.selectedItem != nil{
            let availableTime = availableTimesArray[timeingDropDownVar.selectedItem!]
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = SessionManager.current.selectedRestaurant.timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            let arrivalDateStringInUtc = dateFormatter.string(from: availableTime!)
            parameter["arrival"] = arrivalDateStringInUtc
        }else{
            if bookingData != nil{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                dateFormatter.timeZone = SessionManager.current.selectedRestaurant.timeZone
                let dateToBeDisplayed = dateFormatter.date(from: (bookingData?.arrivalTime)!)
                let dateString = dateFormatter.string(from: dateToBeDisplayed!)
                parameter["arrival"] = dateString
            }else{
                parameter["arrival"] = (Any?).none
            }
        }
        if bookingTypeVar.selectedItem != nil{
            parameter["bookingType"] = bookingTypeVar.selectedItem
        }else{
            if bookingData != nil{
                parameter["bookingType"] = (Any?).none
            }else{
                parameter["bookingType"] = bookingData?.bookingType
            }
        }
        parameter["dne"] = 0
        if durationDropDownVar.selectedItem != nil{
            let durationString = durationDropDownVar.selectedItem
            let duration = durationString?.dropLast(4)
            parameter["duration"] = duration
        }else{
            if bookingData != nil{
                parameter["duration"] = bookingData?.duration
            }else{
                parameter["duration"] = 0
            }
        }
        if peopleDropDownVar.selectedItem != nil{
            
            parameter["guests"] = peopleDropDownVar.selectedItem
        }else{
            if bookingData != nil{
                parameter["guests"] = bookingData?.guests
            }else{
                parameter["guests"] = 0
            }
        }
        if bookingData != nil{
            parameter["id"] = bookingData?.bookingId
        }else{
            parameter["id"] = (Any?).none
        }
        
        parameter["internalNotes"] = bookingData?.internalNotes
        parameter["notes"] = notes.text
        parameter["notifyEmail"] = emailConfirmation.on
        parameter["notifySms"] = smsConfirmation.on
        parameter["notifyPayment"] = manualPayment.on
        parameter["online"] = 0
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        if bookingStatusDropDownVar.selectedItem != nil{
            
            parameter["status"] = peopleDropDownVar.selectedItem
        }else{
            if bookingData != nil{
                parameter["status"] = bookingData?.status
            }else{
                parameter["status"] = NSNull()
            }
        }
        var user = [String: Any?]()
        user["id"] = (Any?).none
        if bookingData != nil{
            user["id"] = bookingData?.user.id
        }
        user["name"] = guestName.text
        user["email"] = mailId.text
        user["mobile"] = guestPhoneNumber.text
        user["notes"] = notes.text
        user["vip"] = vipCheckBox.on
        parameter["user"] = user

        if bookingData != nil{
            ConnectionManager.put("/booking/\(String(describing: (bookingData?.bookingId)!))", body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
            self.view.isUserInteractionEnabled = true
                if status == 200{
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else if status == 401{//token expired
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        let vc = Utilities.alertViewController(title: "Update failed", msg: "Try Again!")
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            })
            
        }else{
            ConnectionManager.post("/booking", body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
                self.view.isUserInteractionEnabled = true
                if status == 200{
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else if status == 401{//token expired
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        let vc = Utilities.alertViewController(title: "Update failed", msg: "Try Again!")
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }
            })

        }
    }

    
    func getTimes(){
        
        let format = DateFormatter()
        format.timeZone = SessionManager.current.selectedRestaurant.timeZone
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        var today = format.string(from: Date())
        if (bookingData != nil && bookingData?.arrivalTime != ""){
            let time = (bookingData?.arrivalTime)!
            today = time
        }
        //print(today)
        //print(SessionManager.current.selectedRestaurant.id)
        var parameter = [String: String]()
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        parameter["date"] = today
        ConnectionManager.get("/availability/times", showProgressView: true, parameter: parameter as [String : AnyObject], completionHandler: {(status, response) in
            
            if status == 200{
                if let responseArray = response as? [[String: Any]]{
                    self.availableTimesArray.removeAll()
                    for each in responseArray{
                        if let times = each["times"] as? [[String: Any]]{
                            for time in times{
                                if let available = time["available"] as? Bool{
                                    if available{
                                        if let minutes = time["time"] as? Int{
                                            var calendar = Calendar.current
                                            calendar.timeZone = SessionManager.current.selectedRestaurant.timeZone!
                                            let dateAtMidnight = calendar.startOfDay(for: Date())
                                            let availableDateAndTime = dateAtMidnight.addMinutes(minutesToAdd: minutes)
                                            self.availableTimesArray["\(minutes/60):\(minutes%60)"] = availableDateAndTime
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.timeingDropDownVar.dataSource = Array(self.availableTimesArray.keys)
                    }
                    
                }
            }else if status == 401{//token expired
                
            }
            
        })
    }
    func getBookingTypes(){
        let querydict = ["active": "true", "deleted": "false"]
        var queryString = ""
        do{
            let queryDictToData = try JSONSerialization.data(withJSONObject: querydict, options: .init(rawValue: 0))
            queryString = String(data: queryDictToData, encoding: .utf8)!
        }catch{
            print("Couldn't parse!!")
        }
        var parameter = [String: String]()
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        parameter["q"] = queryString
        parameter["sort"] = "name"
        ConnectionManager.get("/booking-type", showProgressView: false, parameter: parameter as [String : AnyObject] , completionHandler: {
        (status, response) in
            if status == 200{
                if let responseArray = response as? [[String: Any]]{
                    for each in responseArray{
                        self.bookingTypeArray.append(each["name"] as! String)
                    }
                    DispatchQueue.main.async {
                        self.bookingTypeVar.dataSource = self.bookingTypeArray
                    }
                }
            }else if status == 401{//token expired
                
            }
        })
    }
    func getAvailableTables(){
        
        var parameter = [String: Any]()
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        let format = DateFormatter()
        format.timeZone = SessionManager.current.selectedRestaurant.timeZone
        //format.timeZone = TimeZone(abbreviation: "UTC")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        parameter["omit"] = nil
        var today = format.string(from: Date())
        if (bookingData != nil && bookingData?.arrivalTime != ""){
            let timeString = (bookingData?.arrivalTime)!
            let todayTime = format.date(from: timeString)
            today = format.string(from: todayTime!)
            parameter["guests"] = String(describing: (bookingData?.guests)!)
            parameter["duration"] = String(describing: (bookingData?.duration)!)
            print(bookingData?.bookingId)
            parameter["omit"] = bookingData?.bookingId
        }else{
            parameter["guests"] = "0"
            parameter["duration"] = "0"
        }
        parameter["arrival"] = today
        
        ConnectionManager.get("/availability/tables", showProgressView: false, parameter: parameter as [String : AnyObject] , completionHandler: {
            (status, response) in
            if status == 200{
                if let responseArray = response as? [[String: Any]]{
                    for each in responseArray{
                        self.tablesArray[each["name"] as! String] = each["id"] as? String
                    }
                    DispatchQueue.main.async {
                        self.numberOfTableVar.dataSource = Array(self.tablesArray.keys)
                    }
                }
            }else if status == 401{//token expired
                
            }
        })

    }
    
    @IBAction func onDropDown(_ sender: UIButton) {
        if sender.tag == 101{
            timeingDropDownVar.show()
        }else if sender.tag == 102{
            durationDropDownVar.show()
        }else if sender.tag == 103{
            peopleDropDownVar.show()
        }else if sender.tag == 104{
            numberOfTableVar.show()
        }else if sender.tag == 105{
            bookingTypeVar.show()
        }else if sender.tag == 106{
            bookingStatusDropDownVar.show()
        }
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let scrollingHeight = notes.frame.origin.y + 10 - (self.view.frame.height - keyboardSize.height)
            if scrollingHeight > 0{
                contentScrollView.contentOffset = CGPoint(x: 0, y: scrollingHeight + 90)
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
}










