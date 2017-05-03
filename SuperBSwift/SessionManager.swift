//
//  SessionManager.swift
//  SuperBSwift
//
//  Created by Nauroo on 30/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class SessionManager: NSObject {
    static let current = SessionManager()
    var userInfo =  UserInfo()
    var userLoggedIn = false
}
class UserInfo: NSObject{
    var id = ""
    var name = ["first": "", "last": ""]
    var email = ""
    var zipCode = ""
    var mobile = ""
    var hasCard = false
    var token = ""
    var isNew = false
    var manager = false
    var staff = false
    var admin = false
    var restaurants: [RestaurantInfo] = []
    
    convenience init(id: String?, name: [String: String]?, email: String?, zipCode: String?, mobile: String?, hasCard: Bool?, token: String?, isNew: Bool?, manager: Bool?, staff: Bool?, admin: Bool?, restaurants: [RestaurantInfo]?){
        self.init()
        if id != nil{
            self.id = id!
        }
        if name != nil{
            if let first = name?["first"]{
                self.name["first"] = first
            }
            if let last = name?["last"]{
                self.name["last"] = last
            }
        }
        if email != nil{
            self.email = email!
        }
        if zipCode != nil{
            self.zipCode = zipCode!
        }
        if mobile != nil{
            self.mobile = mobile!
        }
        if hasCard != nil{
            self.hasCard = hasCard!
        }
        if token != nil{
            self.token = token!
        }
        if isNew != nil{
            self.isNew = isNew!
        }
        if manager != nil{
            self.manager = manager!
        }
        if staff != nil{
            self.staff = staff!
        }
        if admin != nil{
            self.admin = admin!
        }
        if restaurants != nil{
            self.restaurants = restaurants!
        }
    }
}
class RestaurantInfo: NSObject{
    var name = ""
    var created = Date()
    var id = ""
    convenience init(name: String?, created: Date?, id: String?){
        self.init()
        if name != nil{
            self.name = name!
        }
        if id != nil{
            self.id = id!
        }
        if created != nil{
             self.created = created!
        }
    }
    }
