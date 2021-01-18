//
//  MyCalenderCell.swift
//  accountBook
//
//  Created by Choi SeungHyuk on 2021/01/19.
//
import Foundation
import UIKit
import FSCalendar

class MyCalenderCell: FSCalendarCell {
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        self.shapeLayer.isHidden = true
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
