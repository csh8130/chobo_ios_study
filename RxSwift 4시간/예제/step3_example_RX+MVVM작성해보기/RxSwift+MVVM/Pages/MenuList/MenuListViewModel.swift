//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by Choi SeungHyuk on 2020/12/22.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    let menus: [MenuItem] = []
    let itemsCount: Int = 5
    let totalPrice: Observable<Int> = Observable.just(10_000)
}
