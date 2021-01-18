//
//  ViewController.swift
//  accountBook
//
//  Created by Choi SeungHyuk on 2021/01/05.
//

import UIKit
import FSCalendar

struct AccountDayData {
    var date: Date
    var amount: String
}

class ViewController: UIViewController {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewTop: NSLayoutConstraint!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var dictionary: [Date: [AccountDayData]] = [:]
//    var selection: Date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavGradient()
        UIApplication.shared.statusBarStyle = .lightContent
        
        setTitleMonth(calendar)
        calendar.placeholderType = .fillSixRows
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dictionary[calendar.today!] = []
        setupView()
    }
    
    func setupView() {
        
        calendar.register(MyCalenderCell.self, forCellReuseIdentifier: "cell")
    }
    
    func setNavGradient() {
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.init(red: 115/256, green: 196/256, blue: 177/256, alpha: 1).cgColor, UIColor.init(red: 114/256, green: 186/256, blue: 211/256, alpha: 1).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            
            if let image = getImageFrom(gradientLayer: gradient) {
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
            }
        }
    }


    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    func setTitleMonth(_ calendar: FSCalendar) {
        let month = Calendar.current.component(.month, from: calendar.currentPage)
        title = "\(month)월"
    }
    @IBAction func addButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else {
            return
        }
        
        vc.closeHandler = { [weak self] amount in
            guard let self = self else { return }
            self.dictionary[self.calendar.selectedDate!]?.append(AccountDayData(date: self.calendar.selectedDate!, amount: amount))
            self.tableView.reloadData()
        }
        
        if calendar.selectedDate == nil {
            vc.date = calendar.today
        } else {
            vc.date = calendar.selectedDate
        }
        
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setTitleMonth(calendar)
        let lastDay = lastDayInMonth(calendar.currentPage)
        let weekCount = nthWeek(lastDay)
        let height = CGFloat(6 - weekCount) * calendar.visibleCells()[0].fs_height

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [weak self] () -> Void in
                        guard let self = self else { return }
                        self.bottomViewTop.constant = height
                        self.view.layoutIfNeeded()
                       }, completion: { [weak self] _ in
                       })
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        tableView.reloadData()
        refreshVisibleCells(selecteddate: date, selectedmonthPosition: monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    //private func
    
    func nthWeek(_ d: Date) -> Int {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "W"
        let nth = formatter.string(from: d)
        return Int(nth) ?? -1
    }
    
    func lastDayInMonth(_ date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko")

        //여기에 기입하지 않은 날짜는 1로 초기화가 된다
        let components = calendar.dateComponents([.year, .month], from: date)

        //day를 기입하지 않아서 현재 달의 첫번쨰 날짜가 나오게 된다
        let startOfMonth = calendar.date(from: components)!
        let comp1 = calendar.dateComponents([.day,.weekday,.weekOfMonth], from: startOfMonth)

        //이번 달의 마지막 날짜를 구해주기 위해서 다음달을 구한다 이것도 day를 넣어주지 않았기 때문에 1이 다음달의 1일이 나오게 된다
        let nextMonth = calendar.date(byAdding: .month, value: +1, to: startOfMonth)

        //위에 값에서 day값을 넣어주지 않았기 떄문에 1이 나오게 되므로 마지막 날을 알기 위해서 -1을 해준다
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to:nextMonth!)
        
        return endOfMonth!
    }
    
    func test(_ date: Date) { //그 달의 첫째날, 마지막날 구해서 그 사이를 순회
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko")

        //여기에 기입하지 않은 날짜는 1로 초기화가 된다
        let components = calendar.dateComponents([.year, .month], from: date)

        //day를 기입하지 않아서 현재 달의 첫번쨰 날짜가 나오게 된다
        let startOfMonth = calendar.date(from: components)!
        let comp1 = calendar.dateComponents([.day,.weekday,.weekOfMonth], from: startOfMonth)

        //이번 달의 마지막 날짜를 구해주기 위해서 다음달을 구한다 이것도 day를 넣어주지 않았기 때문에 1이 다음달의 1일이 나오게 된다
        let nextMonth = calendar.date(byAdding: .month, value: +1, to: startOfMonth)

        //위에 값에서 day값을 넣어주지 않았기 떄문에 1이 나오게 되므로 마지막 날을 알기 위해서 -1을 해준다
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to:nextMonth!)
                
        let comp2 = calendar.dateComponents([.day,.weekday,.weekOfMonth], from: endOfMonth!)
        let weekArr = calendar.shortWeekdaySymbols

        if let weekday = comp1.weekday, let weekday2 = comp2.weekday {
            print(weekArr[weekday-1])
            print(weekArr[weekday2-1])
        }
        //이 달의 첫번째 날과 끝날을 구했으니깐 그 사이의 날짜는 for문을 통해서 구하면 된다
        //현재 만들어 놓은 달력의 label변수들을 배열에 저장하여서 for문을 돌면서 차례대로 값을 집어 넣으면 되는데
        //label값에 entry값을 집어 넣는 위치는 첫번째 날짜의 weekday를 기준으로 하면 된다
        for i in comp1.day!...comp2.day! {
            print(i)
        }
    }
    
    func refreshVisibleCells(selecteddate: Date, selectedmonthPosition: FSCalendarMonthPosition) {
        calendar.visibleCells().forEach { calendarCell in
            let date = calendar.date(for: calendarCell)
            guard let cell = calendarCell as? MyCalenderCell else {
                return
            }
            if date == selecteddate {
                cell.select(nil)
            } else {
                cell.deselect()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var day: Date? = calendar.selectedDate
        
        if calendar.selectedDate == nil {
            day = calendar.today
        }
        if dictionary[day!] == nil {
            dictionary[day!] = []
        }
        
        return dictionary[day!]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as? MainCell else {
            return UITableViewCell()
        }
        cell.title.text = "\(dictionary[calendar.selectedDate!]![indexPath.row].date)"
        cell.won.text = "\(dictionary[calendar.selectedDate!]![indexPath.row].amount)"
        return cell
    }
}
