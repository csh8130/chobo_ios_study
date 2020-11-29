//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    private var storeItem: MenuItem = MenuItem(name: "", price: 0)
    var item: MenuItem {
        get {
            return storeItem
        }
        set {
            storeItem = newValue
            title.text = newValue.name
            count.text = "0"
            price.text = "\(newValue.price)"
        }
    }
    
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!

    @IBAction func onIncreaseCount() {
    }

    @IBAction func onDecreaseCount() {
    }
}
