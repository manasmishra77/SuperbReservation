//
//  DashboardTableViewCell.swift
//  SuperBSwift
//
//  Created by Nauroo on 08/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var numberOfPepole: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var importantImageView: UIImageView!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var locationImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
