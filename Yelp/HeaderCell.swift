//
//  HeaderCell.swift
//  Yelp
//
//  Created by minh on 11/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit



class HeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}

