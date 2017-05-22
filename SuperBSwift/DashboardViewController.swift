//
//  DashboardViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 01/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController,UIViewControllerTransitioningDelegate, MenuViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var headingDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedRestaurant: RestaurantInfo?
    var refreshControl = UIRefreshControl()
    var querieDay = Date()
    var bookingArray = [ReservationInfo]()
    var selectedIndex: Int?
    var moreTableArray = [String]()

    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(hex: 0xAD9557, alpha: 0.6)
        navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        //RefreshControl
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!")
        refreshControl.addTarget(self, action: #selector(DashboardViewController.viewDidAppear(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        //Date format
        let format = DateFormatter()
        format.dateFormat =  "EEEE d'th' LLLL"
        let today = format.string(from: querieDay)
        headingDateLabel.text = today
        moreTableView.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    
    func reloadData(){
        let format = DateFormatter()
        format.dateFormat =  "EEEE d'th' LLLL"
        let today = format.string(from: querieDay)
        headingDateLabel.text = today
        getBookings()
    }
    func getBookings(){
        refreshControl.isEnabled = false
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        format.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        var components = calendar?.components([.year, .month, .weekOfYear, .weekday], from: querieDay)
        components?.hour = 0
        components?.minute = 0
        let startDate = calendar?.date(from: components!)
        components?.hour = 23
        components?.minute = 59
        let endDate = calendar?.date(from: components!)
        let startTime = format.string(from: startDate!)
        let endTime = format.string(from: endDate!)
        
        var query = [String: String]()
        query["restaurant"] = selectedRestaurant?.id
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
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 101{
            return moreTableArray.count
        }
        
        //print(bookingArray.count)
        return bookingArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //More Table view cell
        if tableView.tag == 101{
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
            moreCell.textLabel?.text = moreTableArray[indexPath.row]
            return moreCell
        }
        //Dashboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableCell", for: indexPath) as! DashboardTableViewCell
        let bookingDict = bookingArray[indexPath.row]
        cell.nameLabel.text = "\(String(describing: bookingDict.user.name["first"]!)) \(String(describing: bookingDict.user.name["last"]!))"
        cell.importantImageView.isHidden = !bookingDict.user.vip
        //Arrival Time
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        let arrivalDate = format.date(from: bookingDict.arrivalTime)
        format.dateFormat = "HH:mm"
        let startTime = format.string(from: arrivalDate!)
        var comps = DateComponents()
        //print(comps.minute!)
        comps.minute = bookingDict.duration
        let endDate = calendar?.date(byAdding: comps, to: arrivalDate!, options: NSCalendar.Options(rawValue: 0))
        let endTime = format.string(from: endDate!)
        cell.timelabel.text = "\(startTime) - \(endTime)"
        //Number of people
        cell.numberOfPepole.text = "\(bookingDict.guests) people"
        let url = bookingDict.user.photoUrl
        cell.imageUser.adoptCircularShape()
        cell.imageUser.downloadedFrom(link: url, contentMode: .scaleAspectFit)
        
        return cell
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 101{
            let selectedStatus = moreTableArray[indexPath.row]
            if selectedStatus == "Dismiss"{
                tableView.isHidden = true
                return
            }
            var parameter = [String: String]()
            parameter["status"] = selectedStatus
            let bookingInfo = self.bookingArray[selectedIndex!]
            let urlString = "/booking/\(bookingInfo.bookingId)"
            ConnectionManager.put(urlString, body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
                if status == 200{
                    self.bookingArray[self.selectedIndex!].status = selectedStatus
                    DispatchQueue.main.async {
                        self.moreTableView.isHidden = true
                        self.tableView.reloadData()
                    }
                    
                }
                self.selectedIndex = nil
            })
            
        }else{
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
        vc.navigationTitle.title = "Edit Reservation"
        vc.bookingData = bookingArray[indexPath.row]
        present(vc, animated: true, completion: nil)
        }
        

    }
    //Adding swiping cell functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        selectedIndex = indexPath.row
        let cancelled = UITableViewRowAction(style: .normal, title: "Cancelled") { action, index in
            let selectedStatus = "cancel"
            var parameter = [String: String]()
            parameter["status"] = selectedStatus
            let bookingInfo = self.bookingArray[self.selectedIndex!]
            let urlString = "/booking/\(bookingInfo.bookingId)"
            ConnectionManager.put(urlString, body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
                if status == 200{
                    self.bookingArray.remove(at: self.selectedIndex!)
                DispatchQueue.main.async {
                        self.moreTableView.isHidden = true
                        self.tableView.reloadData()
                    }

                }
                self.selectedIndex = nil
            })

        }
        cancelled.backgroundColor = UIColor.red
        
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            
            let bookingDict = self.bookingArray[indexPath.row]
            self.moreTableArray.removeAll()
            if bookingDict.status == "hold"{
                
                self.moreTableArray = ["confirmed", "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "Dismiss"]
            }else if bookingDict.status == "new"{
                self.moreTableArray = ["confirmed", "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "no-show", "Dismiss"]
            }else if bookingDict.status == "confirmed"{
                self.moreTableArray = [ "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "no-show", "Dismiss"]
            }else if bookingDict.status == "left-message"{
                self.moreTableArray = [ "confirmed", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "no-show", "Dismiss"]
            }
            else if bookingDict.status == "partially-arrived"{
                self.moreTableArray = [ "arrived", "partially-seated", "seated", "completed", "no-show", "Dismiss"]
            }else if bookingDict.status == "arrived"{
                self.moreTableArray = [ "partially-seated", "seated", "completed", "no-show", "Dismiss"]
            }else if bookingDict.status == "partially-seated"{
                self.moreTableArray = [ "seated", "completed", "no-show", "Dismiss"]
            }else if bookingDict.status == "seated"{
                self.moreTableArray = [ "completed", "no-show", "Dismiss"]
            }
            if self.moreTableArray.count > 1{
                self.moreTableView.isHidden = false
                self.moreTableView.delegate = self
                self.moreTableView.dataSource = self
                self.moreTableView.reloadData()
            }
            
        }
        more.backgroundColor = UIColor.blue
        
        return [cancelled, more]
    }
    
    
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
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardViewController
        //self.navigationController?.setViewControllers([vc], animated: false)
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

    @IBAction func nextDateButon(_ sender: Any) {
            let interval = TimeInterval(60 * 60 * 24 * 1)
            querieDay = querieDay.addingTimeInterval(interval)
            reloadData()
    }
    @IBAction func previousDateButton(_ sender: Any) {
        let interval = TimeInterval(-60 * 60 * 24 * 1)
        querieDay = querieDay.addingTimeInterval(interval)
        reloadData()
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
    @IBAction func onAddNewButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
        //vc.navigationTitle.title = "New Reservation"
        //vc.bookingData = bookingArray[indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
}























