//
//  ViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 26/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var restaurantTableView: UITableView!
    
    var restaurants: [RestaurantInfo] = []
    
    var selectedRestaurant = RestaurantInfo()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor(hex: 0xAD9557, alpha: 0.6)
        loginCheckUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        loginCheckUp()
    }
    
    //Login Check
    func loginCheckUp() {
        //if let userLogIn = UserDefaults.standard.object(forKey: "UserLoggedIn") as? Bool{
         if let userLogIn = SessionManager.current.userLoggedIn as? Bool{
            if userLogIn{
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                let userInfoDict = SessionManager.current.userInfo
                if let userInfoDict = userInfoDict as? UserInfo{
                    if userInfoDict.restaurants.count > 1{
                       restaurantTableView.delegate = self
                       restaurantTableView.dataSource = self
                        restaurants = userInfoDict.restaurants
                    }else if userInfoDict.restaurants.count == 1{
                        selectedRestaurant = userInfoDict.restaurants[0]
                        changeToDashboardViewcontroller()
                    }
                    
                }
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                self.navigationController?.pushViewController(vc!, animated: false)
            }
            
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell", for: indexPath)
        cell.textLabel?.text = restaurants[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedRestaurant.created = restaurants[indexPath.row].created
        selectedRestaurant.id = restaurants[indexPath.row].id
        selectedRestaurant.name = restaurants[indexPath.row].name
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        changeToDashboardViewcontroller()
        }
    func changeToDashboardViewcontroller(){
        print(selectedRestaurant.id)
        SessionManager.current.selectedRestaurant = selectedRestaurant
        if selectedRestaurant.id != ""{
            //to Dashboard viewcontroller
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardViewController
            vc.selectedRestaurant = selectedRestaurant
            self.navigationController?.setViewControllers([vc], animated: true)
        }

    }

}

