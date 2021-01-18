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
        selectionView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.fs_width-1, height: contentView.fs_height-1))
        selectionView?.backgroundColor = .yellow
        selectionView?.isHidden = true
        self.contentView.insertSubview(selectionView ?? UIView(), at: 0)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
