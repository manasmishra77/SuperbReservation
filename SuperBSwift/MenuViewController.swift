//
//  MenuViewController.swift
//  NaurooSitters
//
//  Created by Nauroo on 4/21/15.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate
{
    func showPendingJobs()
    func showCompletedJobs()
    func showCalendar()
    func showAvailability()
    func showLogout()
    
    func showOpacityLayer()
    func hideOpacityLayer()
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var sitterNameLabel: UILabel!
    
    var delegate: MenuViewControllerDelegate?
    
    var options = ["List View", "Calendar", "Waiting list", "Search", "Choose Restaurant", "Analytics", "Log out"]
    
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        delegate?.showOpacityLayer()
        
        profilePictureImageView.adoptCircularShape()
        profilePictureImageView.layer.borderColor = UIColor.white.cgColor
        profilePictureImageView.layer.borderWidth = 2.0
        
        sitterNameLabel.text = UserDefaults.standard.object(forKey: "name") as? String
        
        if let profilePicture = UserDefaults.standard.object(forKey: "profilePicture") as? String, let uuidUser = UserDefaults.standard.object(forKey: "uuidUser") as? String
        {
           
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")
        
        let option = options[indexPath.row]
        cell?.textLabel?.text = option
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        delegate?.hideOpacityLayer()
        
        let option = options[indexPath.row]
        
        if (option.contains("Log out"))
        {
            UIApplication.shared.unregisterForRemoteNotifications()
            self.dismiss(animated: false, completion: {
                self.delegate?.showLogout()
            })
        }
        else if (option.contains("Log out"))
        {
            self.dismiss(animated: false, completion: {
                self.delegate?.showCalendar()
            })
        }
        else if (option.contains("Log out"))
        {
            self.dismiss(animated: false, completion: {
                self.delegate?.showPendingJobs()
            })        }
        else if (option.contains("Log out"))
        {
            self.dismiss(animated: false, completion: {
                self.delegate?.showCompletedJobs()
            })
        }
        else if (option.contains("Log out"))
        {
            self.dismiss(animated: false, completion: {
                self.delegate?.showAvailability()
            })
        }
    }
    
    @IBAction func close(_ sender: AnyObject)
    {
        delegate?.hideOpacityLayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    override var canBecomeFirstResponder : Bool
    {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if let view = touch.view
        {
            if view.isDescendant(of: tableView)
            {
                return false
            }
        }
        
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
}
