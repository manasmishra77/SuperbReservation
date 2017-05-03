//
//  MenuTableViewCell.swift
//  NaurooSitters
//
//  Created by Nauroo on 4/21/15.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
