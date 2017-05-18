//
//  AnalyticsWeeklyTableViewCell.swift
//  SuperBSwift
//
//  Created by Nauroo on 14/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class AnalyticsWeeklyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var guestForWeek: UILabel!
    @IBOutlet weak var reservationForWeek: UILabel!
    @IBOutlet weak var waitingListForWeek: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
