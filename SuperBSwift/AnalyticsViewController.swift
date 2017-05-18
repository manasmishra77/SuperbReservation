//
//  AnalyticsViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 14/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController, UIViewControllerTransitioningDelegate, MenuViewControllerDelegate {
    
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthName: UILabel!
    @IBOutlet weak var weekTableView: UITableView!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var waitingListCount: UILabel!
    @IBOutlet weak var reservationCount: UILabel!
    
    @IBOutlet weak var monthButton: UIButton!
    var querieDay = Date()
    
    var bookingArray = [ReservationInfo]()
    var bookingDict = [String: [ReservationInfo]]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func weekOrMonthButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func nextMonthButtonTapped(_ sender: Any) {
        querieDay = querieDay.addDays(daysToAdd: 30)
        getBookings()
        
    }
    @IBAction func previuosMonthButtonTapped(_ sender: Any) {
        querieDay = querieDay.addDays(daysToAdd: 30)
        getBookings()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        getBookings()
    }
    
    func reloadingViews(){
        
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
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnalyticsVC") as! AnalyticsViewController
        //self.navigationController?.setViewControllers([vc], animated: false)
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarViewController
        self.navigationController?.setViewControllers([vc], animated: false)
        
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
    
    func getBookings(){
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        format.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        var components = calendar?.components([.year, .month], from: querieDay)
        components?.hour = 0
        components?.minute = 0
        components?.day = 1
        let startDate = calendar?.date(from: components!)
        components?.month = (components?.month)! + 1
        let endDateOfTheMonth = (calendar?.date(from: components!))?.addHours(hoursToAdd: -24)
        components?.hour = 23
        components?.minute = 59
        let endDate = calendar?.date(from: components!)
        
        let startTime = format.string(from: startDate!)
        let endTime = format.string(from: endDate!)
        
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
        ConnectionManager.get("/booking/dashboard", showProgressView: false, parameter: parameter as [String : AnyObject], completionHandler: {(status, response) in
            if status == 500{
                let alert = Utilities.alertViewController(title: "Network Error", msg: "Try Again!!")
                self.present(alert, animated: true, completion: nil)
            }else{
                if status == 200{
                    if let responseArray = response as? [[String: AnyObject]]{
                        self.convertingToModel(arr: responseArray)
                        self.dateWiseArranging()
                        DispatchQueue.main.async {
                            self.reloadingViews()
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
        for bookingInfo in bookingArray{
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let keyDate = format.date(from: bookingInfo.arrivalTime)
            format.dateFormat = "yyyy-MM-dd"
            let keyString = format.string(from: keyDate!)
            print("Date:  \(keyString)")
            
            if bookingDict[keyString] != nil{
                bookingDict[keyString]?.append(bookingInfo)
            }else{
                let arrayDict = [bookingInfo]
                bookingDict[keyString] = arrayDict
            }
        }
    }


}
