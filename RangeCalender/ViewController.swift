//
//  ViewController.swift
//  RangeCalender
//
//  Created by Karan V on 02/03/24.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    @IBOutlet weak var txtField: UITextField!
    
    @IBOutlet weak var calendarView: JTACYearView!
    var strYear = ""
    let f = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        calendarView.register(UINib(nibName: "MonthCell", bundle: nil), forCellWithReuseIdentifier: "MonthCellk")
        calendarView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellWithReuseIdentifier: "HeaderCellk")
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(actionP))
        setUI()
    }
    func setUI() {
        calendarView.calendarDataSource  = self
        calendarView.calendarDelegate  = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BACK")
    }
    @IBAction func btnAction(_ sender: UIButton) {
        strYear = txtField.text ?? ""
        setUI()
        calendarView.reloadData()
    }
//    @objc func actionP() {
//        let otherAlert = UIAlertController(title: "Multiple Actions", message: "The alert has more than one action which means more than one button.", preferredStyle: UIAlertController.Style.alert)
//
//        let printSomething = UIAlertAction(title: "Print", style: UIAlertAction.Style.default) { _ in
//            print("We can run a block of code." )
//        }
//
//        let callFunction = UIAlertAction(title: "Call Function", style: UIAlertAction.Style.destructive, handler: {_ in
//            print("HEllo")
//        })
//
//        let dismiss = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
//
//        // relate actions to controllers
//        otherAlert.addAction(printSomething)
//        otherAlert.addAction(callFunction)
//        otherAlert.addAction(dismiss)
//        present(otherAlert, animated: true, completion: nil)
//    }
    
}

extension ViewController: JTACYearViewDelegate, JTACYearViewDataSource {
    func calendar(_ calendar: JTAppleCalendar.JTACYearView, cellFor item: Any, at date: Date, indexPath: IndexPath) -> JTAppleCalendar.JTACMonthCell {
        if item is Month {
            let cell = calendar.dequeueReusableJTAppleMonthCell(withReuseIdentifier: "MonthCellk", for: indexPath) as! MonthCell
            f.dateFormat = "MMM"
            cell.lblMonth.text = f.string(from: date)
            return cell
        } else {
            let cell = calendar.dequeueReusableJTAppleMonthCell(withReuseIdentifier: "HeaderCellk", for: indexPath) as! HeaderCell
            f.dateFormat = "yyyy"
            cell.lblYear.text = f.string(from: date)
            return cell
        }
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACYearView, monthView: JTAppleCalendar.JTACCellMonthView, drawingFor segmentRect: CGRect, with date: Date, dateOwner: JTAppleCalendar.DateOwner, monthIndex index: Int) {
        let f = DateFormatter()
        f.dateFormat = "d"
        let dateString = f.string(from: date)
        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont(name: "HelveticaNeue", size: 9)!
        if dateOwner == .thisMonth {
            let isToday = Calendar.current.isDateInToday(date)
            let textColor: UIColor = isToday ? .white : .black
            let redOpacity = UIColor(red: 245.0 / 255.0, green: 15.0 / 255.0, blue: 15.0 / 255.0, alpha: 0.9)
            let circleColor: UIColor = isToday ? redOpacity : .clear
            let circleRect = CGRect(x: segmentRect.origin.x + (segmentRect.width - 12) / 2,
                                    y: segmentRect.origin.y + (segmentRect.height - 18) / 2,
                                    width:12,
                                    height: 12)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            circleColor.setFill()
            circlePath.fill()
            let fontBold = UIFont.boldSystemFont(ofSize: 10)
            paragraphStyle.alignment = .center
            dateString.draw(in: segmentRect, withAttributes: [
                NSAttributedString.Key.font : isToday ? fontBold : font,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: textColor
            ])
        }
        else {
            paragraphStyle.alignment = .center
            dateString.draw(in: segmentRect, withAttributes: [
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ])
        }
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACYearView, sizeFor item: Any) -> CGSize {
        if item is Month {
            let width = (calendar.frame.width - 41 ) / 3
            let height = width
            return CGSize(width: width + 5, height: height + 50)
        } else {
            let width = calendar.frame.width - 41
            let height:CGFloat  = 45
            return CGSize(width: width + 6, height: height)
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendar.JTACYearView) -> (configurationParameters: JTAppleCalendar.ConfigurationParameters, months: [Any]) {
        let df = DateFormatter()
        df.dateFormat = "yyyy MM dd"
        let currentYear = Calendar.current.component(.year, from: Date())
        var startDate = Date()
        var endDate = Date()
        if strYear == "" {
            startDate = df.date(from: "\(currentYear) 01 01")!
            endDate = df.date(from: "\(currentYear + 12) 12 31")!
        } else {
            startDate = df.date(from: "\(strYear) 01 01")!
            endDate = df.date(from: "\(strYear) 12 31")!
        }
        let configParams = ConfigurationParameters(startDate: startDate,
                                                   endDate: endDate,
                                                   numberOfRows: 6,
                                                   calendar: Calendar(identifier: .gregorian),
                                                   generateInDates: .forAllMonths,
                                                   generateOutDates: .tillEndOfGrid,
                                                   firstDayOfWeek: .sunday,
                                                   hasStrictBoundaries: true)
        
        // Generate the data source for the calendar
        let dataSource = calendar.dataSourcefrom(configurationParameters: configParams)
        
        // Modify the data source to include a "Year" label every 12 months
        var modifiedDataSource: [Any] = []
        for index in (0..<dataSource.count) {
            if index % 12 == 0 { modifiedDataSource.append("Year") }
            modifiedDataSource.append(dataSource[index])
        }
        
        return (configParams, modifiedDataSource)
//        let df = DateFormatter()
//        df.dateFormat = "yyyy MM dd"
//        let startDate = df.date(from: "2022 01 01")!
//        let endDate = df.date(from: "2050 05 31")!
//        let configParams = ConfigurationParameters(startDate: startDate,
//                                                   endDate: endDate,
//                                                   numberOfRows: 6,
//                                                   calendar: Calendar(identifier: .gregorian),
//                                                   generateInDates: .forAllMonths,
//                                                   generateOutDates: .tillEndOfGrid,
//                                                   firstDayOfWeek: .sunday,
//                                                   hasStrictBoundaries: true)
//        let dataSource = calendar.dataSourcefrom(configurationParameters: configParams)
//        var modifiedDataSource: [Any] = []
//        for index in (0..<dataSource.count) {
//            if index % 12 == 0 { modifiedDataSource.append("Year") }
//            modifiedDataSource.append(dataSource[index])
//        }
//
//        return (configParams, modifiedDataSource)
    }
    
    
}
