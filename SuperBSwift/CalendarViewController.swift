//
//  CalendarViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 11/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit
import JTCalendar

class CalendarViewController: UIViewController, JTCalendarDelegate, UIViewControllerTransitioningDelegate, MenuViewControllerDelegate {
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var waitingListLabel: UILabel!
    @IBOutlet weak var reservationLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var guestLabel: UILabel!
    @IBOutlet weak var calenderContentView: JTHorizontalCalendarView!
    
    var bookingArray = [ReservationInfo]()
    var bookingDict = [String: [ReservationInfo]]()
    
    var selectedDate = Date()
    var querieDay = Date()
    var minDate = Date()
    var maxDate = Date()
    let calendarManager = JTCalendarManager.init()
    var nextday: Date?
    var previousDay: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = true
        calendarManager.delegate = self
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calenderContentView
        calendarManager.setDate(selectedDate)
        var calendar = Calendar.current
        calendar.timeZone = SessionManager.current.selectedRestaurant.timeZone!
        var components = calendar.dateComponents([.year, .month], from: selectedDate)
        fillingTheHeadingLabels()
        let startOfTheMonth = calendar.date(from: components)
        components.year = 0
        components.month = 3
        maxDate = calendar.date(byAdding: components, to: startOfTheMonth!, wrappingComponents: false)!
        components.month = -2
        minDate = calendar.date(byAdding: components, to: startOfTheMonth!, wrappingComponents: false)!
        
    }
    override func viewDidAppear(_ animated: Bool) {
        reload()
    }
    func reload(){
        getBookings()
        
    }
    func getBookings(){
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //format.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
        format.timeZone = SessionManager.current.selectedRestaurant.timeZone
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        calendar?.timeZone = SessionManager.current.selectedRestaurant.timeZone!
        var components = calendar?.components([.year, .month], from: querieDay)
        components?.hour = 0
        components?.minute = 0
        components?.day = 1
        //components?.timeZone = SessionManager.current.selectedRestaurant.timeZone
        let startDate = calendar?.date(from: components!)
        components?.month = (components?.month)! + 1
        nextday = calendar?.date(from: components!)
        let endDateOfTheMonth = nextday?.addMinutes(minutesToAdd: -1)
        components?.month = (components?.month)! - 2
        previousDay = calendar?.date(from: components!)
        let startTime = format.string(from: startDate!)
        let endTime = format.string(from: endDateOfTheMonth!)
        
        var query = [String: String]()
        query["restaurant"] = SessionManager.current.selectedRestaurant.id
        query["startDate"] = startTime
        query["endDate"] = endTime
        var jsonString = ""
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: query, options: .init(rawValue: 0))
            jsonString = String(data: jsonData, encoding: .utf8)!
        }catch{
            print("Couldn't parse!!")
        }
        var parameter = [String: String]()
        parameter["q"] = jsonString
        parameter["sort"] = "arrival"
        parameter["populate"] = "user"
        ConnectionManager.get("/booking/dashboard", showProgressView: true, parameter: parameter as [String : AnyObject], completionHandler: {(status, response) in
            if status == 500{
                let alert = Utilities.alertViewController(title: "Network Error", msg: "Try Again!!")
                self.present(alert, animated: true, completion: nil)
            }else{
                if status == 200{
                    if let responseArray = response as? [[String: AnyObject]]{
                        self.convertingToModel(arr: responseArray)
                        self.dateWiseArranging()
                        DispatchQueue.main.async {
                            self.calendarManager.reload()
                        }
                    }
                }else if status == 400{
                    if let response = response as? [String: AnyObject]{
                        DispatchQueue.main.async {
                            let alert = Utilities.alertViewController(title: "Error", msg: response["message"] as! String)
                            self.present(alert, animated: true, completion: nil)
                            self.view.isUserInteractionEnabled = true
                        }
                    }
                }else if status == 401{//token expired
                    
                    DispatchQueue.main.async {
                        self.showLogout()
                    }
                    
                    
                }else{
                    DispatchQueue.main.async {
                        let alert = Utilities.alertViewController(title: "Server Error", msg: "Try Again!!")
                        self.present(alert, animated: true, completion: nil)
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            
        })
        
    }

    
    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        let myDayView = dayView as! JTCalendarDayView
        myDayView.isHidden = false
        if myDayView.isFromAnotherMonth{
            myDayView.isHidden = true
        }
        //Today
        else if calendarManager.dateHelper.date(Date(), isTheSameDayThan: myDayView.date){
            myDayView.circleView.isHidden = false
            myDayView.circleView.backgroundColor = UIColor.blue
            myDayView.dotView.backgroundColor = UIColor.white
            myDayView.textLabel.textColor = UIColor.white
        }
        //Selected Date
        else if ((calendarManager.dateHelper.date(selectedDate, isTheSameDayThan: myDayView.date))){
            myDayView.circleView.isHidden = false
            myDayView.circleView.backgroundColor = UIColor.red
            myDayView.dotView.backgroundColor = UIColor.white
            myDayView.textLabel.textColor = UIColor.white
        }
        //Another day of the current month
        else{
            myDayView.circleView.isHidden = true
            myDayView.dotView.backgroundColor = UIColor.red
            myDayView.textLabel.textColor = UIColor.black
        }
        
        // Your method to test if a date have an event for example
        if (haveAnEvent(querieDate: myDayView.date)){
            myDayView.dotView.isHidden = false
        }else{
            myDayView.dotView.isHidden = true
        }
    }
    //Limit the calendar
    func calendar(_ calendar: JTCalendarManager!, canDisplayPageWith date: Date!) -> Bool {
        return calendarManager.dateHelper.date(date, isEqualOrAfter: minDate, andEqualOrBefore: maxDate)
    }
    //Respond a touch on a dayview
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        let myDayView = dayView as! JTCalendarDayView
        selectedDate = myDayView.date
        fillingTheHeadingLabels()
        //Filling lower view
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let keyString = format.string(from: selectedDate)
        var guests = 0
        var reservations = 0
        var waitingList = 0
        if let bookingDictArrayDayWise = bookingDict[keyString]{
            for each in bookingDictArrayDayWise{
                guests = each.guests + guests
                reservations = reservations + 1
                if each.status == "waiting-list"{
                    waitingList = waitingList + 1
                    reservations = 0
                }
            }
        }
        guestLabel.text = String(guests)
        reservationLabel.text = String(reservations)
        waitingListLabel.text = String(waitingList)
        
        UIView.transition(with: myDayView, duration: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: {
            myDayView.circleView.transform = CGAffineTransform.identity
            self.calendarManager.reload()
        }, completion: nil)
        
        if(!calendarManager.dateHelper.date(calenderContentView.date, isTheSameMonthThan: myDayView.date)){
            if(calenderContentView.date.compare(myDayView.date) == ComparisonResult.orderedAscending)
            {
                calenderContentView.loadNextPageWithAnimation()
            }
            else{
                calenderContentView.loadPreviousPageWithAnimation()
            }
        }
    }
    func calendarDidLoadNextPage(_ calendar: JTCalendarManager!) {
        querieDay = nextday!
        reload()
    }
    func calendarDidLoadPreviousPage(_ calendar: JTCalendarManager!) {
        querieDay = previousDay!
        reload()
    }
    
    func haveAnEvent(querieDate: Date) -> Bool{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let keyString = format.string(from: querieDate)
        if bookingDict[keyString] != nil {
            return true
        }
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        reload()
    }
    @IBAction func addNewButtonTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationViewController")
        self.present(vc!, animated: true, completion: nil)
    }
    
    //MenuViewPresentation
    @IBAction func menuButtontapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
    //MARK: UIViewControllerAnimatedTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return DashboardTransitionAnimator(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return DashboardTransitionAnimator(presenting: false)
    }
    
    //Delegate Methods of MenuViewControllerDelegate
    func showLogout(){
        UserDefaults.standard.set(false, forKey: "UserLoggedIn")
        showChooseRestaurant()
    }
    func showAnalysis() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnalyticsVC") as! AnalyticsViewController
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    func showDashBoard() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardViewController
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    func showSearchView() {
        
    }
    func showWaitingList() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WitingListVC") as! WitingListViewController
        self.navigationController?.setViewControllers([vc], animated: false)
        
    }
    func showCalenderView() {
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarViewController
        //self.navigationController?.setViewControllers([vc], animated: false)
        
    }
    func showChooseRestaurant() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChooseRestaurantVC") as! ViewController
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    func showOpacityLayer()
    {
        let layer = CALayer()
        layer.name = "opacityLayer"
        layer.frame = view.bounds
        layer.backgroundColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        view.layer.addSublayer(layer)
    }
    
    func hideOpacityLayer()
    {
        if let opacityLayer = view.layer.sublayers?.filter({$0.name == "opacityLayer"}).first
        {
            if let index = view.layer.sublayers?.index(of: opacityLayer)
            {
                view.layer.sublayers?.remove(at: index)
            }
        }
    }
    func fillingTheHeadingLabels(){
        // Filling the heading labels
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: selectedDate)
        dateFormatter.dateFormat = "EEEE d'th'"
        dayLabel.text = dateFormatter.string(from: selectedDate)
    }
    
    func convertingToModel(arr: [[String: AnyObject]]){
        bookingArray.removeAll()
        for bookingDict in arr{
            var userInfo: UserInfo?
            if let userInfoDict =  bookingDict["user"] as? Dictionary<String, Any>{
                var restaurants: [RestaurantInfo]? = [RestaurantInfo]()
                if let restaurantArray = userInfoDict["restaurants"] as? [[String:Any]]{
                    for restaurant in restaurantArray{
                        let newRestaurant = RestaurantInfo(name: restaurant["name"] as? String, created: restaurant["created"] as? Date, id: restaurant["id"] as? String)
                        restaurants?.append(newRestaurant)
                    }
                }
                userInfo = UserInfo(id: userInfoDict["id"] as? String, name: userInfoDict["name"] as? [String: String], email: userInfoDict["email"] as? String, zipCode: userInfoDict["zipCode"] as? String, mobile: (userInfoDict["mobile"] as? String)!, hasCard: userInfoDict["hasCard"] as? Bool, token: userInfoDict["token"] as? String, isNew: userInfoDict["isNew"] as? Bool, manager: userInfoDict["manager"] as? Bool, staff: userInfoDict["staff"] as? Bool, admin: userInfoDict["admin"] as? Bool, vip: userInfoDict["vip"] as? Bool, photoUrl: userInfoDict["profilePictureUrl"] as? String, restaurants: restaurants)
            }
            let booking = ReservationInfo(bookingId: bookingDict["bookingId"] as? String, bookingType: bookingDict["bookingType"] as? String, arrivalTime: bookingDict["arrival"] as? String, duration: bookingDict["duration"] as? Int, guests: bookingDict["guests"] as? Int, code: bookingDict["code"] as? String, created: bookingDict["created"] as? String, deleted: bookingDict["deleted"] as? Int, internalNotes: bookingDict["internalNotes"] as? String, modified: bookingDict["modified"] as? String, notes: bookingDict["notes"] as? String, online: bookingDict["online"] as? Int, paid: bookingDict["paid"] as? Int, paymentAssociated: bookingDict["paymentAssociated"] as? Int, restaurant: bookingDict["restaurant"] as? String, status: bookingDict["status"] as? String, supplements: bookingDict["supplements"] as? String, takeAway: bookingDict["takeAway"] as? Int, turnaround: bookingDict["turnaround"] as? Int, walkIn: bookingDict["walkIn"] as? Int, arrTables: bookingDict["arrTables"] as? [AnyObject], user: userInfo)
            
            bookingArray.append(booking)
        }
    }
    func dateWiseArranging(){
        bookingDict.removeAll()
        let bA = bookingArray
        for bookingInfo in bookingArray{
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            format.timeZone = SessionManager.current.selectedRestaurant.timeZone
            let keyDate = format.date(from: bookingInfo.arrivalTime)
            format.dateFormat = "yyyy-MM-dd"
            let keyString = format.string(from: keyDate!)
            
            if bookingDict[keyString] != nil{
                bookingDict[keyString]?.append(bookingInfo)
            }else{
                let arrayDict = [bookingInfo]
                bookingDict[keyString] = arrayDict
            }
        }
    }



}
