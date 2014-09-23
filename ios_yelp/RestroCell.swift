//
//  RestroCell.swift
//  ios_yelp
//
//  Created by Faith Cox on 9/20/14.
//  Copyright (c) 2014 Yahoo. All rights reserved.
//

import UIKit

class RestroCell: UITableViewCell {

    @IBOutlet weak var restroView: UIImageView!
    @IBOutlet weak var restronameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
