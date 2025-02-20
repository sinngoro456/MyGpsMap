//
//  View_Pin.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import Foundation
import UIKit

class Viw_Pin: UIView {
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = color
        self.layer.cornerRadius = frame.width / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
