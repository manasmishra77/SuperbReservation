//
//  SignInViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 30/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var validEmail = true //change
    var validPassword = true //change
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userNameTF.delegate = self
        passwordTF.delegate = self
        userNameTF.text = "demo@dinesuperb.com" //change
        passwordTF.text = "ds2017" //change

        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFieldShouldReturn(textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 101{
            if (textField.text?.isEmail)!{
                validEmail = true
                
            }else{
                validEmail = false
                Utilities.alertBubble("Isn't a valid email", view: self.view)
            }
        }else{
            if (textField.text?.isEmpty)!{
                validPassword = false
                Utilities.alertBubble("Enter password", view: self.view)
            }else{
                validPassword = true
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        let connectedToInterNet = Utilities.isConnectedToNetwork()
        if !connectedToInterNet{
            let alert = Utilities.alertViewController(title: "No internet", msg: "Check your internet connection!")
            self.present(alert, animated: true, completion: nil)
            return
        }
        if validPassword && validEmail && connectedToInterNet{
            view.isUserInteractionEnabled = false
            let loginBody = ["username": userNameTF.text, "password": passwordTF.text]
            ConnectionManager.post("/signin", body: loginBody as AnyObject, useToken: false, showProgressView: true, completionHandler: {(status, response) in
                
                self.view.isUserInteractionEnabled = true
                if status == 500{
                    let alert = Utilities.alertViewController(title: "Network Error", msg: "Try Again!!")
                    self.present(alert, animated: true, completion: nil)
                }else{
                    if status == 200{
                        if let userInfoDict =  response as? Dictionary<String, Any>{
                            var restaurants: [RestaurantInfo]? = [RestaurantInfo]()
                            if let restaurantArray = userInfoDict["restaurants"] as? [[String:Any]]{
                                for restaurant in restaurantArray{
                                    let newRestaurant = RestaurantInfo(name: restaurant["name"] as? String, created: restaurant["created"] as? Date, id: restaurant["id"] as? String)
                                    restaurants?.append(newRestaurant)
                                }
                            }                            
                            let userInfo = UserInfo(id: userInfoDict["id"] as? String, name: userInfoDict["name"] as? [String: String], email: userInfoDict["email"] as? String, zipCode: userInfoDict["zipCode"] as? String, mobile: (userInfoDict["mobile"] as? String)!, hasCard: userInfoDict["hasCard"] as? Bool, token: userInfoDict["token"] as? String, isNew: userInfoDict["isNew"] as? Bool, manager: userInfoDict["manager"] as? Bool, staff: userInfoDict["staff"] as? Bool, admin: userInfoDict["admin"] as? Bool,vip: userInfoDict["vip"] as? Bool, photoUrl: userInfoDict["photoUrl"] as? String, restaurants: restaurants)
                            let current = SessionManager.current
                            current.userInfo = userInfo
                            current.userLoggedIn = true
                            //UserDefaults.standard.set(true, forKey: "UserLoggedIn")
                            //UserDefaults.standard.set(userInfo, forKey: "UserInfo")
                            DispatchQueue.main.async {
                                self.navigationController?.popToRootViewController(animated: false)
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
                    }else{
                        DispatchQueue.main.async {
                            let alert = Utilities.alertViewController(title: "Server Error", msg: "Try Again!!")
                            self.present(alert, animated: true, completion: nil)
                            self.view.isUserInteractionEnabled = true
                        }
                    }
                }
            })
        }else if !validPassword && validEmail{
            let alertController = Utilities.alertViewController(title: "Wrong password", msg: "Enter a valid password")
            self.present(alertController, animated: true, completion: nil)
        }else{
            let alertController = Utilities.alertViewController(title: "Invalid email", msg: "Enter a valid emailid")
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let scrollingHeight = passwordTF.frame.origin.y + 10 - (self.view.frame.height - keyboardSize.height)
            if scrollingHeight > 0{
                backgroundScrollView.contentOffset = CGPoint(x: 0, y: scrollingHeight + 40)
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            backgroundScrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    

}






























