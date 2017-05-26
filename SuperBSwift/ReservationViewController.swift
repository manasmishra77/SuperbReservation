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
        
        vipCheckBox.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        emailConfirmation.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        smsConfirmation.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        manualPayment.onTintColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        vipCheckBox.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        emailConfirmation.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        smsConfirmation.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        manualPayment.onCheckColor = UIColor(hex: 0xAD9557, alpha: 1.0)
        
        var _: [DropDown] = {
            return [self.bookingStatusDropDownVar, self.peopleDropDownVar,self.numberOfTableVar, self.timeingDropDownVar,self.durationDropDownVar, self.bookingTypeVar]
        }() 
        
        bookingStatusDropDownVar.dataSource = ["cancel", "no-show", "completed", "confirmed", "hold", "new", "left-message", "partially-arrived", "arrived", "partially-seated", "seated"]
        peopleDropDownVar.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "32", "32", "33", "34", "35", "36"]
        durationDropDownVar.dataSource = ["15 min", "30 min", "45 min", "60 min", "90 min", "120 min", "150 min", "180 min", "210 min", "240 min", "270 min", "300 min"]
        getTimes()
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
            contentView.isUserInteractionEnabled = false
            guestPhoneNumber.text = bookingData?.user.mobile
            bookingStatusDropDown.setTitle(bookingData?.status, for: .normal)
            peopleDropDown.setTitle(String(describing: (bookingData?.guests)!), for: .normal)
            durationDropDown.setTitle("\(String(describing: (bookingData?.duration)!)) min", for: .normal)
            
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
    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onDone(_ sender: Any) {
        contentView.isUserInteractionEnabled = false
        var parameter = [String: Any]()
        var userId = ""
        if bookingData != nil {
            parameter["id"] = bookingData?.bookingId
            parameter["internalNotes"] = bookingData?.internalNotes
            userId = (bookingData?.user.id)!
        }else{
             parameter["id"] = ""
            parameter["internalNotes"] = ""
        }
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        if timeingDropDownVar.selectedItem != nil{
            let availableTime = availableTimesArray[timeingDropDownVar.selectedItem!]
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
            let arrivalDateStringInUtc = dateFormatter.string(from: availableTime!)
            parameter["arrival"] = arrivalDateStringInUtc
        }else{
            parameter["arrival"] = ""
        }
        parameter["duration"] = ""
        if durationDropDownVar.selectedItem != nil{
            parameter["duration"] = durationDropDownVar.selectedItem
        }
        parameter["guests"] = ""
        if peopleDropDownVar.selectedItem != nil{
            parameter["guests"] = peopleDropDownVar.selectedItem
        }
        parameter["tables"] = ""
        if numberOfTableVar.selectedItem != nil{
            parameter["tables"] = [tablesArray[numberOfTableVar.selectedItem!]]
        }
        parameter["status"] = ""
        if bookingStatusDropDownVar.selectedItem != nil{
            parameter["status"] = bookingStatusDropDownVar.selectedItem
        }
        parameter["bookingType"] = ""
        if bookingTypeVar.selectedItem != nil{
            parameter["bookingType"] = bookingTypeVar.selectedItem
        }
        
        parameter["notes"] = notes.text
        parameter["online"] = "0"
        parameter["walkIn"] = "0"
        parameter["notifyEmail"] = emailConfirmation.on
        parameter["notifySms"] = smsConfirmation.on
        parameter["notifyPayment"] = manualPayment.on
        parameter["dne"] = "0"
        
        var user = [String: String]()
        user["id"] = userId
        user["name"] = guestName.text
        user["email"] = mailId.text
        user["mobile"] = guestPhoneNumber.text
        user["notes"] = notes.text
        parameter["user"] = user
        
        if bookingData != nil{
            ConnectionManager.put("/booking/\(String(describing: (bookingData?.bookingId)!))", body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
            
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
    @IBAction func onEdit(_ sender: Any) {
        contentView.isUserInteractionEnabled = !contentView.isUserInteractionEnabled
    }
    
    func getTimes(){
        
        let format = DateFormatter()
        format.timeZone = TimeZone(abbreviation: "UTC")
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
        ConnectionManager.get("/availability/times", showProgressView: false, parameter: parameter as [String : AnyObject], completionHandler: {(status, response) in
            
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
                                            calendar.timeZone = TimeZone.current
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
        format.timeZone = TimeZone(abbreviation: "UTC")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        var today = format.string(from: Date())
        if (bookingData != nil && bookingData?.arrivalTime != ""){
            let time = (bookingData?.arrivalTime)!
            today = time
        }
        parameter["arrival"] = today
        parameter["guests"] = String(describing: (bookingData?.guests)!)
        parameter["duration"] = String(describing: (bookingData?.duration)!)
        parameter["omit"] = "_id"
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
    
}










