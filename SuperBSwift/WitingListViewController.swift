//
//  WitingListViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 14/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class WitingListViewController: UIViewController, UIViewControllerTransitioningDelegate, MenuViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreTableView: UITableView!
    var refreshControl = UIRefreshControl()
    //var bookingArray = [ReservationInfo]()
    //let querieDay = Date()
    var selectedIndex: Int?
    var moreTableArray = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let format = DateFormatter()
        format.timeZone = SessionManager.current.selectedRestaurant.timeZone
        format.dateFormat =  "EEEE d'th' LLLL"
        navigationItem.title = format.string(from: SessionManager.current.querieDay!)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WitingListVC") as! WitingListViewController
        //self.navigationController?.setViewControllers([vc], animated: false)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 101{
            return moreTableArray.count
        }
        return SessionManager.current.waitingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //More Table view cell
        if tableView.tag == 101{
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "MoreWaitingCell", for: indexPath)
            moreCell.textLabel?.text = moreTableArray[indexPath.row]
            return moreCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaitingListCell", for: indexPath) as! WaitingListTableViewCell
        let bookingDict = SessionManager.current.waitingList[indexPath.row]
        cell.nameLabel.text = "\(String(describing: bookingDict.user.name["first"]!)) \(String(describing: bookingDict.user.name["last"]!))"
        cell.importantImageView.isHidden = !bookingDict.user.vip
        //Arrival Time
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        format.timeZone = SessionManager.current.selectedRestaurant.timeZone
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
                self.tableView.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 1.0)
                self.tableView.reloadData()
                //coverView.isHidden = true
                return
            }
            var parameter = [String: String]()
            parameter["status"] = selectedStatus
            let bookingInfo = SessionManager.current.waitingList[selectedIndex!]
            let urlString = "/booking/\(bookingInfo.bookingId)"
            ConnectionManager.put(urlString, body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
                if status == 200{
                    SessionManager.current.waitingList[self.selectedIndex!].status = selectedStatus
                    DispatchQueue.main.async {
                        self.moreTableView.isHidden = true
                        //self.coverView.isHidden = true
                        self.tableView.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 1.0)
                        self.tableView.reloadData()
                    }
                    
                }
                self.selectedIndex = nil
                DispatchQueue.main.async {
                    //self.coverView.isHidden = true
                    self.tableView.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 1.0)
                }
                
            })
            
        }else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
            //vc.navigationTitle.title = "Edit Reservation"
            vc.bookingData = SessionManager.current.waitingList[indexPath.row]
            present(vc, animated: true, completion: nil)
        }

    }
    //Adding swiping cell functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView.tag == 101{
            return nil
        }
        selectedIndex = indexPath.row
        let cancelled = UITableViewRowAction(style: .normal, title: "Cancelled") { action, index in
            let selectedStatus = "cancel"
            var parameter = [String: String]()
            parameter["status"] = selectedStatus
            let bookingInfo = SessionManager.current.waitingList[self.selectedIndex!]
            let urlString = "/booking/\(bookingInfo.bookingId)"
            ConnectionManager.put(urlString, body: parameter as AnyObject, useToken: true, showProgressView: true, completionHandler: {(status, response) in
                if status == 200{
                    SessionManager.current.waitingList.remove(at: self.selectedIndex!)
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
            
            let bookingDict = SessionManager.current.waitingList[indexPath.row]
            self.moreTableArray.removeAll()
            if bookingDict.status == "hold"{
                
                self.moreTableArray = ["confirmed", "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "Dismiss"]
            }else if bookingDict.status == "new"{
                self.moreTableArray = ["confirmed", "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "Dismiss"]
            }else if bookingDict.status == "confirmed"{
                self.moreTableArray = [ "left-message", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "Dismiss"]
            }else if bookingDict.status == "left-message"{
                self.moreTableArray = [ "confirmed", "partially-arrived", "arrived", "partially-seated", "seated", "completed", "Dismiss"]
            }
            else if bookingDict.status == "partially-arrived"{
                self.moreTableArray = [ "arrived", "partially-seated", "seated", "completed", "Dismiss"]
            }else if bookingDict.status == "arrived"{
                self.moreTableArray = [ "partially-seated", "seated", "completed", "Dismiss"]
            }else if bookingDict.status == "partially-seated"{
                self.moreTableArray = [ "seated", "completed", "Dismiss"]
            }else if bookingDict.status == "seated"{
                self.moreTableArray = [ "completed", "Dismiss"]
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
   

}
