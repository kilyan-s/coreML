//
//  RoundedShadowImageView.swift
//  image-detection
//
//  Created by Kilyan SOCKALINGUM on 17/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

   override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.75
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.cornerRadius = 15
    }
}
