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

class ReservationViewController: UIViewController, BEMCheckBoxDelegate {
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var vipCheckBox: BEMCheckBox!
    @IBOutlet weak var guestPhoneNumber: UITextField!
    @IBOutlet weak var guestPhoto: UIImageView!
    @IBOutlet weak var guestName: UITextField!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var mailId: UITextField!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var bookingStatusDropDown: DropDown!
    @IBOutlet weak var peopleDropDown: DropDown!
    @IBOutlet weak var numberOfTable: DropDown!
    @IBOutlet weak var timeingDropDown: DropDown!
    @IBOutlet weak var durationDropDown: DropDown!
    @IBOutlet weak var bookingType: DropDown!
    @IBOutlet weak var confirmationWay: DropDown!
    
    var bookingData: ReservationInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetting()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Initial Setting or on edit button
    func initialSetting(){
        bookingStatusDropDown.dataSource = ["cancel", "no-show", "completed", "confirmed", "hold", "new", "left-message", "partially-arrived", "arrived", "partially-seated", "seated", ]
        peopleDropDown.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
        numberOfTable.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
        durationDropDown.dataSource = ["15 min", "30 min", "45 min", "60 min", "90 min", "120 min", "150 min", "180 min", "210 min", "240 min", "270 min", "300 min"]
        
        let format = DateFormatter()
        format.timeZone = TimeZone(abbreviation: "UTC")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        var today = format.string(from: Date())
        if (bookingData != nil && bookingData?.arrivalTime != ""){
            let time = (bookingData?.arrivalTime)!
           today = time
        }
        print(today)
        print(SessionManager.current.selectedRestaurant.id)
        var parameter = [String: String]()
        parameter["restaurant"] = SessionManager.current.selectedRestaurant.id
        parameter["date"] = today
        ConnectionManager.get("/availability/times", showProgressView: true, parameter: parameter as [String : AnyObject], completionHandler: {(status, response) in
        
            if status == 200{
                if let responseArray = response as? [[String: Any]]{
                    for each in responseArray{
                        if let times = each["times"] as? [[String: Any]]{
                            
                        }
                    }
                }
            }else if status == 401{//token expired
                
            }
        
        })
        
        
        if bookingData != nil{
            contentView.isUserInteractionEnabled = false
            guestPhoneNumber.text = bookingData?.user.mobile
            let url = bookingData?.user.photoUrl
            guestPhoto.adoptCircularShape()
            guestPhoto.downloadedFrom(link: url!, contentMode: .scaleAspectFit)
            guestName.text = "\(String(describing: bookingData?.user.name["first"]!)) \(String(describing: bookingData?.user.name["last"]!))"
            mailId.text = bookingData?.user.email
            notes.text = bookingData?.notes
            
        }
        
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
    }
    @IBAction func onDone(_ sender: Any) {
    }
    @IBAction func onEdit(_ sender: Any) {
        contentView.isUserInteractionEnabled = true
    }
    
}
