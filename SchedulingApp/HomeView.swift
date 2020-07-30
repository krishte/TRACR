//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}

struct PageViewControllerWeeks: UIViewControllerRepresentable {
    @Binding var nthdayfromnow: Int

    var viewControllers: [UIViewController]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[Int(Double(self.nthdayfromnow / 7).rounded(.down))]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewControllerWeeks

        init(_ pageViewController: PageViewControllerWeeks) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                 return nil
            }
            
            if index == 0 {
                return nil
            }
 
            return parent.viewControllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.viewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            if index + 1 == parent.viewControllers.count {
                return nil
            }
            
            return parent.viewControllers[index + 1]
        }
    }
}

struct WeeklyBlockView: View {
    @Binding var nthdayfromnow: Int
    @EnvironmentObject var changingDate: DisplayedDate

    let datenumberindices: [Int]
    let datenumbersfromlastmonday: [String]
    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    ZStack {
                        Circle().fill(self.datenumberindices[index] == self.nthdayfromnow ? Color("datenumberred") : Color.white).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3)
                        Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(.regular)
                    }.onTapGesture {
                        self.nthdayfromnow = self.datenumberindices[index]
                    
                    }
                }
                
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))

//            HStack {
//                Rectangle().frame(width: 5).foregroundColor(Color("datenumberred"))
//                Spacer()
//            }
        }
    }
}
 
struct SubassignmentAddTimeAction: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @Binding var offsetvar: CGFloat
    @Binding var subassignmentname: String
    @Binding var addhours: Int
    @Binding var addminutes: Int
    
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    var body : some View {
        VStack(spacing: 15) {
            HStack {
                Text("\(self.subassignmentname)").font(.system(size: 18)).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
            }
            
            HStack {
                VStack {
                    Picker(selection: $addhours, label: Text("Hour")) {
                        ForEach(hourlist.indices) { hourindex in
                            Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                         }
                     }.pickerStyle(WheelPickerStyle())
//                    Button(action: {print("sdfdsfdsf")})
//                    { Text(" + Add Even More Time") }
                }.frame(minWidth: 100, maxWidth: .infinity)
                .clipped()
                
                VStack {
                    if addhours == 0 {
                        Picker(selection: $addminutes, label: Text("Minutes")) {
                            ForEach(minutelist[1...].indices) { minuteindex in
                                Text(String(self.minutelist[minuteindex]) + " mins")
                            }
                        }.pickerStyle(WheelPickerStyle())
                    }
                    
                    else {
                        Picker(selection: $addminutes, label: Text("Minutes")) {
                            ForEach(minutelist.indices) { minuteindex in
                                Text(String(self.minutelist[minuteindex]) + " mins")
                            }
                        }.pickerStyle(WheelPickerStyle())
                    }
                }.frame(minWidth: 100, maxWidth: .infinity)
                .clipped()
            }
            
            HStack {
                Button(action: {
                    for (_, element) in self.assignmentlist.enumerated() {
                        if (element.name == self.subassignmentname) {
                            element.timeleft += Int64(60*self.hourlist[self.addhours] + self.minutelist[self.addminutes])
                            element.totaltime += Int64(60*self.hourlist[self.addhours] + self.minutelist[self.addminutes])
                            element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                        }
                    }
                    
                    for (index, element) in self.subassignmentlist.enumerated() {
                        if (element.assignmentname == self.subassignmentname) {
                            self.managedObjectContext.delete(self.subassignmentlist[index])
                        }
                    }
                    
                    do {
                        try self.managedObjectContext.save()
                        print("Subassignment time added")
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    self.offsetvar = UIScreen.main.bounds.size.width
                })
                { Text("Add Time to Assignment").font(.system(size: 20)) }
            }
        }.padding(.all, 25).frame(maxHeight: 365).background(Color.white).cornerRadius(25).padding(.all, 14)
    }
}


struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var changingDate: DisplayedDate


    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>
    
    var datesfromlastmonday: [Date] = []
    var daytitlesfromlastmonday: [String] = []
    var datenumbersfromlastmonday: [String] = []
    
    var daytitleformatter: DateFormatter
    var datenumberformatter: DateFormatter
    var formatteryear: DateFormatter
    var formattermonth: DateFormatter
    var formatterday: DateFormatter
    var timeformatter: DateFormatter
    
    let daysoftheweekabr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State var nthdayfromnow: Int = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day!
    
    var hourformatter: DateFormatter
    var minuteformatter: DateFormatter
    var shortdateformatter: DateFormatter
    @State var subassignmentassignmentname: String = ""
    
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    
    @Binding var addhours: Int
    @Binding var addminutes: Int
    @State var selectedColor: String = "one"
    
    
    init(verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, addhours: Binding<Int>, addminutes: Binding<Int>) {
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._addhours = addhours
        self._addminutes = addminutes
        
        daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
        
        datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"
        
        formatteryear = DateFormatter()
        formatteryear.dateFormat = "yyyy"
        
        formattermonth = DateFormatter()
        formattermonth.dateFormat = "MM"
        
        formatterday = DateFormatter()
        formatterday.dateFormat = "dd"
        hourformatter = DateFormatter()
        minuteformatter = DateFormatter()
        self.hourformatter.dateFormat = "HH"
        self.minuteformatter.dateFormat = "mm"
        timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        timeformatter.timeZone = TimeZone(secondsFromGMT: 0)
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.selectedColor  = "one"
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
        let lastmondaydate = Date(timeInterval: TimeInterval(86400 + timezoneOffset), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400+timezoneOffset+1), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400 + timezoneOffset+1), since: Date().startOfWeek!)
        
       // print(lastmondaydate.description)
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate))
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
        }
//        for i in 0...27
//        {
//            print(self.datesfromlastmonday[i], self.daytitlesfromlastmonday[i], self.datenumbersfromlastmonday[i])
//        }
    }
    
    func upcomingDisplayTime() -> String {
        let minuteval = Calendar.current
        .dateComponents([.minute], from: Date(timeIntervalSinceNow: 7200), to: subassignmentlist[0].startdatetime)
        .minute!

        
        if (minuteval > 720 )
        {
            return "No Upcoming Subassignments"
        }
        if (minuteval >= 60 && minuteval < 120)
        {
            return "In 1 hour " + String(minuteval-60) + " mins: "
        }
        return "In " + String(minuteval/60) + " hours " + String(minuteval%60) + " mins: "
        
    }
    
    var body: some View {
        VStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.daysoftheweekabr.indices) { dayofthweekabrindex in
                    Text(self.daysoftheweekabr[dayofthweekabrindex]).font(.system(size: (UIScreen.main.bounds.size.width / 25))).fontWeight(.light).frame(width: (UIScreen.main.bounds.size.width / 29) * 3)
                }
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
            
            PageViewControllerWeeks(nthdayfromnow: $nthdayfromnow, viewControllers: [UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday))]).id(UUID()).frame(height: 50)
            
            Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium)
            
            ZStack {
                if (subassignmentlist.count > 0) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color(subassignmentlist[0].color), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
                }
                else
                {
                    RoundedRectangle(cornerRadius: 20, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("one"), Color("one")]), startPoint: .leading, endPoint: .trailing))//replace color with subassignment color (gradientof subassignment colors, maybe)
                }
                HStack {
                    VStack(alignment: .leading) {
                        if (subassignmentlist.count == 0) {
                            Text("No Upcoming Subassignments")
                        }
                        else if (self.upcomingDisplayTime() == "No Upcoming Subassignments")
                        {
                            Text("No Upcoming Subassignments")
                        }
                        else {
                            Text("Next Upcoming Task:").fontWeight(.semibold)
                            Text(self.upcomingDisplayTime()).frame(width: 150, alignment: .topLeading)
                            
                            Text(subassignmentlist[0].assignmentname).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(height:40)
                            Text(timeformatter.string(from: subassignmentlist[0].startdatetime) + " - " + timeformatter.string(from: subassignmentlist[0].enddatetime)).font(.system(size: 15))
                        }
                    }.frame(width: self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60 : 150)
                    
                    if self.subassignmentassignmentname != "" {
                        Spacer().frame(width: 10)
                        Divider().frame(width: 1).background(Color.black)
                        Spacer().frame(width: 10)
                        VStack(alignment: .leading) {
                            ForEach(self.assignmentlist) { assignment in
                                if (assignment.name == self.subassignmentassignmentname) {
                                    Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 40, alignment: .topLeading)
                                    Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 12))
                                    Text("Type: " + assignment.type).font(.system(size: 12))
                                    UpcomingSubassignmentProgressBar(assignment: assignment)
                                }
                            }
                        }.frame(width: 150)
                    }
                }.padding(10)
                
            }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).animation(.spring())//.padding(10)
            
            VStack {
                ScrollView {
                    ZStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                ForEach((0...24), id: \.self) { hour in
                                    HStack {
                                        Text(String(format: "%02d", hour)).font(.footnote).frame(width: 20, height: 20)
                                        Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-50, height: 0.5)
                                    }
                                }.frame(height: 50)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Spacer()
                            VStack {
                                Spacer().frame(height: 25)

                                ZStack(alignment: .topTrailing) {
                                    ForEach(subassignmentlist) { subassignment in
                                        //bug: some subassignments are being displayed one day to late. Specifically ones around midnight
//                                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: subassignment.startdatetime, toGranularity: .day)) {
                                        if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.shortdateformatter.string(from: self.datesfromlastmonday[self.nthdayfromnow])) {
                                            IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes).padding(.top, CGFloat(subassignment.startdatetime.timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3).onTapGesture {
                                                self.subassignmentassignmentname = subassignment.assignmentname
                                                self.selectedColor = subassignment.color
                                                
//                                                for subassignment in self.subassignmentlist {
//                                                    print(subassignment.startdatetime.description)
//                                                }
                                                
                                                print(self.datesfromlastmonday[self.nthdayfromnow].description)
                                                print(subassignment.startdatetime.description)
                                            }
                                                //was +122 but had to subtract 2*60.35 to account for GMT + 2
                                            }
                                    }.animation(.spring())
                                }
                                Spacer()
                            }
                        }
                        
                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(), toGranularity: .day)) {
                            HStack(spacing: 0) {
                                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                            }.padding(.top, CGFloat(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 120.7 - 1207)
                        }
                    }.animation(.spring())
                }
            }
        }
        
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
}


struct UpcomingSubassignmentProgressBar: View {
    @ObservedObject var assignment: Assignment
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  150, height: 10)
            HStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*150), height:10, alignment: .leading).animation(.spring())
                if (assignment.progress != 100)
                {
                    Spacer()
                }
            }
        }
    }
}


struct IndividualSubassignmentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    var starttime, endtime, color, name, duedate: String
    var actualstartdatetime, actualenddatetime, actualduedate: Date
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @State var dragoffset = CGSize.zero
    
    var subassignmentlength: Int

    var subassignment: Subassignmentnew
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    @Binding var addhours: Int
    @Binding var addminutes: Int
    
    init(subassignment2: Subassignmentnew, verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, addhours: Binding<Int>, addminutes: Binding<Int>) {
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._addhours = addhours
        self._addminutes = addminutes
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        self.endtime = formatter.string(from: subassignment2.enddatetime)
//        print(starttime)
//        print(endtime)
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        formatter2.timeStyle = .none
        self.color = subassignment2.color
        self.name = subassignment2.assignmentname
        self.actualstartdatetime = subassignment2.startdatetime
        self.actualenddatetime = subassignment2.enddatetime
        self.actualduedate = subassignment2.assignmentduedate
        self.duedate = formatter2.string(from: subassignment2.assignmentduedate)
        let diffComponents = Calendar.current.dateComponents([.minute], from: self.actualstartdatetime, to: self.actualenddatetime)
        subassignmentlength = diffComponents.minute!
        subassignment = subassignment2
        //print(subassignmentlength)
    }
        
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color.green) .frame(width: UIScreen.main.bounds.size.width-20, height: 58 +    CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: UIScreen.main.bounds.size.width-30+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
                            if (self.dragoffset.width < -110) {
                                Text("Complete").foregroundColor(Color.white).frame(width:120)
                            }
                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width + 110)
                            }
                        }
                    }
                }
                if (isDraggedleft) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: 58 +  CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
                        }
                        
                        HStack {
                            if (self.dragoffset.width > 150) {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: -150)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: -190)
                            }
                            else {
                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width-300)
                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width-340)
                            }
                        }
                    }
                }
            }
            
            VStack {
                Text(self.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                Text(self.starttime + " - " + self.endtime).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                Spacer()
//                Text("Due Date: " + self.duedate).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
               // Text(self.actualstartdatetime.description)
//                Text(self.actualenddatetime.description)
            }.frame(height: 38 + CGFloat(Double(((subassignmentlength-60)/60))*60.35)).padding(12).background(Color(color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 25, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
                    //self.isDragged = true

                    if (self.dragoffset.width < 0) {
                        self.isDraggedleft = false
                        self.isDragged = true
                    }
                    else if (self.dragoffset.width > 0) {
                        self.isDragged = false
                        self.isDraggedleft = true
                    }
                                        
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 3/4) {
                        self.deleted = true
                    }
                    else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 3/4) {
                        self.incompleted = true
                    }
                }
                .onEnded { value in
                    self.dragoffset = .zero
                    //self.isDragged = false
                    //self.isDraggedleft = false
                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
                            self.incompletedonce = false
                            print("incompleted")
                            
                            self.verticaloffset = 0
                            self.subassignmentname = self.name
                            
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    let minutes = self.subassignmentlength
                                    
                                    self.addhours = Int(minutes / 60)
                                    self.addminutes = Int((minutes - (self.addhours * 60)) / 5)
                                    
                                    element.timeleft -= Int64(minutes)
                                    element.totaltime -= Int64(minutes)
                                    element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                }
                            }
                            
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    self.managedObjectContext.delete(self.subassignmentlist[index])
                                }
                            }
                            
                            do {
                                try self.managedObjectContext.save()
                                print("Subassignment time added")
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        }
                    }
                        
                    else if (self.deleted == true) {
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    let minutes = self.subassignmentlength
                                    element.timeleft -= Int64(minutes)
                                    element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                    if (element.timeleft == 0) {
                                        element.completed = true
                                        for classity in self.classlist {
                                            if (classity.name == element.subject) {
                                                classity.assignmentnumber -= 1
                                            }
                                        }
                                    }
                                }
                            }
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    self.managedObjectContext.delete(self.subassignmentlist[index])
                                }
                            }
                            do {
                                try self.managedObjectContext.save()
                                print("Subassignment completed")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-40)
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var changingDate: DisplayedDate

    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @State var noClassesAlert = false
    
    @State var verticaloffset: CGFloat = UIScreen.main.bounds.height
    @State var subassignmentname = "SubAssignmentNameBlank"
    @State var addhours = 0
    @State var addminutes = 0

    init() {
      //  self.changingDate.displayedDate = Date()
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: UIScreen.main.bounds.size.width / 3.7) {
                    Button(action: {print("settings button clicked")}) {
                        Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                    }
                    
                    Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 5)

                    Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                        Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                    }.contextMenu{
                        Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                            Text("Assignment")
                            Image(systemName: "paperclip")
                        }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                            Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                        }
                        Button(action: {self.NewClassPresenting.toggle()}) {
                            Text("Class")
                            Image(systemName: "list.bullet")
                        }.sheet(isPresented: $NewClassPresenting, content: {
                            NewClassModalView(NewClassPresenting: self.$NewClassPresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                        Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                            Text("Occupied Time")
                            Image(systemName: "clock.fill")
                        }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                        Button(action: {self.NewFreetimePresenting.toggle()}) {
                            Text("Free Time")
                            Image(systemName: "clock")
                        }.sheet(isPresented: $NewFreetimePresenting, content: { NewFreetimeModalView(NewFreetimePresenting: self.$NewFreetimePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                        Button(action: {self.NewGradePresenting.toggle()}) {
                            Text("Grade")
                            Image(systemName: "percent")
                        }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                    }
                }.padding(.top, -5)
                
                HomeBodyView(verticaloffset: $verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes).environmentObject(self.changingDate)
            }
            
            VStack {
                Spacer()
                
                SubassignmentAddTimeAction(offsetvar: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes).offset(y: self.verticaloffset).animation(.spring())
            }.background((self.verticaloffset <= 110 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all))
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
             let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return HomeView().environment(\.managedObjectContext, context).environmentObject(DisplayedDate())
    }
}
