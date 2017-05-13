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
    func showDashBoard()
    func showCalenderView()
    func showAnalysis()
    func showSearchView()
    func showWaitingList()
    func showChooseRestaurant()
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
        tableView.delegate = self
        tableView.dataSource = self
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
            self.dismiss(animated: true, completion: {
                self.delegate?.showLogout()
            })
        }
        else if (option.contains("Analytics"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showAnalysis()
            })
        }
        else if (option.contains("Choose Restaurant"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showChooseRestaurant()
            })        }
        else if (option.contains("Search"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showSearchView()
            })
        }
        else if (option.contains("Waiting list"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showWaitingList()
            })
        }
        else if (option.contains("Calendar"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showCalenderView()
            })
        }
        else if (option.contains("List View"))
        {
            self.dismiss(animated: true, completion: {
                self.delegate?.showDashBoard()
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
