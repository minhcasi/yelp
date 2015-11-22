//
//  DropdownCell.swift
//  Yelp
//
//  Created by minh on 11/21/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit


@objc protocol DropdownCellDelegate {
    optional func dropdownCell(dropDownCell: DropdownCell, didChangeValue iconImage: UIImage)
}

class DropdownCell: UITableViewCell {
    static let ICON_ARROW = "icon-arrow"
    static let ICON_CHECKED = "icon-checked"
    static let ICON_UNCHECK = "icon-uncheck"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var cellView: UIView!
    
    
    var delegate: DropdownCellDelegate!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if delegate != nil {
            self.delegate?.dropdownCell?(self, didChangeValue: iconImage.image!)
        }

    }

    // change the icon base on the context
    func setIconImage(isCollapse : Bool, isChecked : Bool) {
        if isCollapse == true {
            iconImage.image = UIImage(named: DropdownCell.ICON_ARROW)
            return;
        }
        
        if isChecked {
            iconImage.image = UIImage(named: DropdownCell.ICON_CHECKED)
            return;
        }
        
        iconImage.image = UIImage(named: DropdownCell.ICON_UNCHECK)
        return;
    }
}



