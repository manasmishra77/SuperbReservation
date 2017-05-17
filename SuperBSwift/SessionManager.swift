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
    var selectedRestaurant = RestaurantInfo()
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
    var vip =  false
    var photoUrl = ""
    var restaurants: [RestaurantInfo] = []
    
    convenience init(id: String?, name: [String: String]?, email: String?, zipCode: String?, mobile: String?, hasCard: Bool?, token: String?, isNew: Bool?, manager: Bool?, staff: Bool?, admin: Bool?, vip: Bool?, photoUrl: String?, restaurants: [RestaurantInfo]?){
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
        if photoUrl != nil{
            self.photoUrl = photoUrl!
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
        if vip != nil{
            self.vip = vip!
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

class StatisticInfo: NSObject{
    var guests = 0
    var reservations = 0
    var waitinglists = 0
    convenience init(guests: Int?, reservations: Int?, waitinglists: Int?){
        self.init()
        if guests != nil{
            self.guests = guests!
        }
        if reservations != nil{
            self.reservations = reservations!
        }
        if waitinglists != nil{
            self.waitinglists = waitinglists!
        }
    }
}

class ReservationInfo: NSObject{
    var bookingId = ""
    var bookingType = ""
    var arrivalTime = ""
    var duration = 0
    var guests = 0
    var code = ""
    var created = ""
    var deleted = 0
    var internalNotes = ""
    var modified = ""
    var notes = ""
    var online = 0
    var paid = 0
    var paymentAssociated = 0
    var restaurant = ""
    var status = ""
    var supplements = ""
    var takeAway = 0
    var turnaround = 0
    var walkIn = 0
    var arrTables = [AnyObject]()
    var user = UserInfo()
    
    convenience init(bookingId: String?, bookingType: String?, arrivalTime: String?, duration: Int?, guests: Int?, code: String?, created: String?, deleted: Int?, internalNotes: String?, modified: String?, notes: String?, online: Int?, paid: Int?, paymentAssociated: Int?, restaurant: String?, status: String?, supplements:String?, takeAway: Int?, turnaround: Int?, walkIn: Int?, arrTables: [AnyObject]?, user: UserInfo? ) {
        self.init()
        
        if bookingId != nil{
            self.bookingId = bookingId!
        }
        if bookingType != nil{
            self.bookingType = bookingType!
        }
        if arrivalTime != nil{
            self.arrivalTime = arrivalTime!
        }
        if duration != nil{
            self.duration = duration!
        }
        if guests != nil{
            self.guests = guests!
        }
        if code != nil{
            self.code = code!
        }
        if created != nil{
            self.created = created!
        }
        if deleted != nil{
            self.deleted = deleted!
        }
        if internalNotes != nil{
            self.internalNotes = internalNotes!
        }
        if modified != nil{
            self.modified = modified!
        }
        if notes != nil{
            self.notes = notes!
        }
        if online != nil{
            self.online = online!
        }
        if paymentAssociated != nil{
            self.paymentAssociated = paymentAssociated!
        }
        if restaurant != nil{
            self.restaurant = restaurant!
        }
        if status != nil{
            self.status = status!
        }
        if supplements != nil{
            self.supplements = supplements!
        }
        if takeAway != nil{
            self.takeAway = takeAway!
        }
        if turnaround != nil{
            self.turnaround = turnaround!
        }
        if walkIn != nil{
            self.walkIn = walkIn!
        }
        if arrTables != nil{
            self.arrTables = arrTables!
        }
        if user != nil{
            self.user = user!
        }

    }
}





















