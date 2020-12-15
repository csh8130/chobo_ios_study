//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    var onCountChanged: (Int) -> Void = { _ in }
    
    var item: (menu: MenuItem, count: Int)? {
        didSet {
            title.text = item?.menu.name ?? ""
            count.text = "\(item?.count ?? 0)"
            price.text = "\(item?.menu.price ?? 0)"
        }
    }
    
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!

    @IBAction func onIncreaseCount() {
        onCountChanged(1)
    }

    @IBAction func onDecreaseCount() {
        onCountChanged(-1)
    }
}
