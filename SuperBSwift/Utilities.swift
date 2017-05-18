//
//  Utilities.swift
//  NaurooSitters
//
//  Created by Nauroo on 4/21/15.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit
import SystemConfiguration

class Utilities: NSObject
{
    //MARK: Get a URL to a system directory
    class func systemDirectory(_ searchPathDirectory: FileManager.SearchPathDirectory) -> URL?
    {
        do
        {
            return try FileManager.default.url(for: searchPathDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        }
            
        catch
        {
            print("Couldn't get system folder.")
        }
        
        return nil
    }
    
    //MARK: Present a bubble at the bottom of the screen
    class func alertBubble(_ title: String, view: UIView)
    {
        let boundingSize = CGSize(width: view.bounds.width - 32.0, height: view.bounds.height * 0.1)
        
        if let titleFont = UIFont(name: "MyriadPro-Regular", size: 12.0)
        {
            let titleRect = (title as NSString).boundingRect(with: boundingSize, options: NSStringDrawingOptions.usesFontLeading, attributes: [NSFontAttributeName: titleFont], context: nil)
            
            let bubbleFrame = CGRect(x: view.bounds.midX - titleRect.size.width / 2.0 - 8.0, y: view.bounds.maxY - titleRect.size.height - 64.0, width: titleRect.size.width + 16.0, height: titleRect.size.height + 16.0)
            let bubble = UILabel(frame: bubbleFrame)
            bubble.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
            bubble.text = title
            bubble.textColor = UIColor.white
            bubble.textAlignment = NSTextAlignment.center
            if let bubbleFont = UIFont(name: "MyriadPro-Regular", size: 12.0)
            {
                bubble.font = bubbleFont
            }
            bubble.layer.cornerRadius = 10.0
            bubble.layer.masksToBounds = true
            
            bubble.alpha = 0.0
            view.addSubview(bubble)
            
            UIView.animate(withDuration: 2.0, animations: { () -> Void in
                bubble.alpha = 1.0
            }, completion: { (completed: Bool) -> Void in
                UIView.animate(withDuration: 2.0, animations: { () -> Void in
                    bubble.alpha = 0.0
                }, completion: { (completed: Bool) -> Void in
                    bubble.removeFromSuperview()
                }) 
            }) 
        }
    }
    
    
    //MARK: Create a goal circle with percentage and bar color
    class func goalCircle(_ size: CGSize, color: UIColor, percentage: CGFloat) -> CALayer
    {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        let goalCircle = UIBezierPath(ovalIn: rect)
        
        let goalCircleLayer = CAShapeLayer()
        goalCircleLayer.frame = rect
        goalCircleLayer.path = goalCircle.cgPath
        goalCircleLayer.strokeColor = color.cgColor
        goalCircleLayer.lineWidth = 4.0
        goalCircleLayer.fillColor = UIColor.clear.cgColor
        goalCircleLayer.strokeStart = 0.0
        goalCircleLayer.strokeEnd = percentage
        goalCircleLayer.transform = CATransform3DMakeRotation(CGFloat(3.0 * M_PI / 2.0), 0.0, 0.0, 1.0)
        
        return goalCircleLayer
    }
    //Checking internet connection
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    // Presenting alert
    class func alertViewController(title: String, msg: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        return alert
    }


}

extension String
{
    func removeCharacters(_ characters: [String]) -> String
    {
        var cleanString = self
        
        for character in characters
        {
            cleanString = cleanString.replacingOccurrences(of: character, with: "")
        }
        
        return cleanString
    }

    var localized: String {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        }
    //Validate Email
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    //validate Password
    var isValidPassword: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$", options: .caseInsensitive)
            if(regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil){
                
                if(self.characters.count>=6 && self.characters.count<=20){
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        } catch {
            return false
        }
        
    }
    //Adding percent Encoding
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    
    //Validate mobile number
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
}

//MARK: Handle keyboard
extension UIScrollView
{
    func handleKeyboardDidShow(_ keyboardSize: CGSize, focusedView: UIView?)
    {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        
        self.contentInset = contentInsets
        self.scrollIndicatorInsets = contentInsets
        
        if let focus = focusedView
        {
            self.scrollRectToVisible(self.convert(focus.frame, from: focus.superview), animated: true)
        }
    }
    
    func handleKeyboardDidHide()
    {
        self.contentInset = UIEdgeInsets.zero
        self.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension UIView
{
    //MARK: Apply a shadow to a UIView
    func applyShadow(_ color: UIColor = UIColor.black, offset: CGSize = CGSize(width: 0.0, height: 2.0), opacity: Float = 0.3, radius: CGFloat = 4.0)
    {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func adoptCircularShape()
    {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.width / 2.0
    }
    
    //Border color
    func applyBorder(hex: Int)
    {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(hex: hex, alpha: 1.0).cgColor
        self.layer.cornerRadius = 5.0
    }

}

//MARK: Create a UIColor from a hex int 0xXXXXXX
extension UIColor
{
    convenience init(hex: Int, alpha: CGFloat)
    {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: alpha)
    }
}
//Date Extension
extension Date {
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    func addMinutes(minutesToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(minutesToAdd) * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }

    
}
extension UITableView {
    
    //Scroll to bottom
    func tableViewScrollToBottom(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        }
    }
}
extension Dictionary{
    //Build string representation of HTTP parameter dictionary of keys and objects
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
}
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


















