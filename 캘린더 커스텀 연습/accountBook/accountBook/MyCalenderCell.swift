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
    var selectionView: UIView?
    override init!(frame: CGRect) {
        super.init(frame: frame)
        selectionView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.fs_width, height: contentView.fs_height))
        selectionView?.setGradient(color1: UICo#imageLiteral(resourceName: "simulator_screenshot_102E31DD-52E0-4DB9-AFDC-9CA84472D035.png")lor(red: 233.0/256, green: 144.0/256, blue: 196.0/256, alpha: 1), color2: UIColor(red: 235.0/256, green: 174.0/256, blue: 177.0/256, alpha: 1))
        selectionView?.isHidden = true
        self.contentView.insertSubview(selectionView ?? UIView(), at: 0)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func select(_ sender: Any?) {
        selectionView?.isHidden = !isSelected
    }
    
    func deselect() {
        selectionView?.isHidden = !isSelected
    }
}
