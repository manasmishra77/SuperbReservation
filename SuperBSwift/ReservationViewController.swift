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
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Initial Setting or on edit button
    func initialSetting(){
        bookingStatusDropDown.dataSource = ["cancelled", "checked in", "completed", "confirmed", "hold"]
        peopleDropDown.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
        numberOfTable.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
        durationDropDown.dataSource = ["15 min", "30 min", "45 min", "60 min", "90 min", "120 min"]
        timeingDropDown.dataSource = 
        
        
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
