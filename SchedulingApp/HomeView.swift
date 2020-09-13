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
        @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @Binding var nthdayfromnow: Int
    @Binding var lastnthdayfromnow: Int
    @Binding var increased: Bool
    @Binding var stopupdating: Bool
    @EnvironmentObject var changingDate: DisplayedDate
 
    let datenumberindices: [Int]
    let datenumbersfromlastmonday: [String]
    let datesfromlastmonday: [Date]
    
    func getassignmentsbydate(index: Int) -> [String] {
        var ans: [String] = []
       // print("Index: " + String(index))
        for assignment in assignmentlist {
           // let diff = Calendar.current.dateComponents([.day], from: self.datesfromlastmonday[self.datenumberindices[index]], to:
            //assignment.duedate).day
            if (assignment.completed == false) {
                let diff = Calendar.current.isDate(Date(timeInterval: -7200, since: self.datesfromlastmonday[self.datenumberindices[index]]), equalTo: Date(timeInterval: -7200, since: assignment.duedate), toGranularity: .day)
                print(self.datesfromlastmonday[self.datenumberindices[index]], assignment.duedate.description)
                if (diff == true) {
                    //print(assignment.name)
                    ans.append(assignment.color)
                }
            }
        }
        
        return ans
    }
    
    func getassignmentsbydateindex(index: Int, index2: Int) -> String {
        //return getassignmentsbydate(index:index).count
        if (index2 < self.getassignmentsbydate(index: index).count) {
            return self.getassignmentsbydate(index: index)[index2]
        }

        return "one"
    }
    
    func getoffsetfromindex(assignmentsindex: Int, index: Int) -> CGFloat {
        let length = getassignmentsbydate(index: index).count-1
        if (length == 0 || length == -1) {
            return CGFloat(0)
        }
        if (length == 1) {
            return 7*CGFloat(assignmentsindex)-3.5
        }
        if (length == 2) {
            return 7*CGFloat(assignmentsindex)-7
        }
        if (length == 3) {
            return 7*CGFloat(assignmentsindex)-10.5
        }
 
        return CGFloat(CGFloat(assignmentsindex)/CGFloat(length) * 20 - 10)
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    VStack {
                        ZStack {
                            Circle().fill(Color("datenumberred")).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).opacity(self.datenumberindices[index] == self.nthdayfromnow ? 1 : 0)
                          //  Circle().fill(Color("one")).frame(width: 5, height: 5)
 
                            Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(.regular)
                        }.onTapGesture {
                            withAnimation(.spring()) {
                                self.nthdayfromnow = self.datenumberindices[index]
                                self.stopupdating = true
                                
                                if self.lastnthdayfromnow > self.nthdayfromnow {
                                    self.increased = false
                                }
                                
                                else if self.lastnthdayfromnow < self.nthdayfromnow {
                                    self.increased = true
                                }
                                
                                self.lastnthdayfromnow = self.nthdayfromnow
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                                    self.stopupdating = false
                                }
                            }
                        }//.frame(height: 200)
                        ZStack {
                            ForEach(self.getassignmentsbydate(index: index).indices) { index2 in
//                                if (Int(index2) < self.getlenofassignmentsbydate(index: index))
//                                {
                                Circle().fill(Color(self.getassignmentsbydateindex(index: index, index2: index2))).frame(width: 5, height:  5).offset(x: self.getoffsetfromindex(assignmentsindex: index2, index: index))
//                                }
                            }
                        }
                        Spacer()
                    }//.frame(height: 80)
                }
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
//            HStack {
//                Rectangle().frame(width: 5).foregroundColor(Color("datenumberred"))
//                Spacer()
//            }
        }
    }
}
 
struct DummyPageViewControllerForDates: UIViewControllerRepresentable {
    @Binding var increased: Bool
    @Binding var stopupdating: Bool
    
    var viewControllers: [UIViewController]
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([viewControllers[0]], direction: (self.increased ? .forward : .reverse), animated: self.stopupdating)//reverse/forward based on change
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: DummyPageViewControllerForDates
 
        init(_ pageViewController: DummyPageViewControllerForDates) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard parent.viewControllers.firstIndex(of: viewController) != nil else {
                 return nil
            }
            
            return nil
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard parent.viewControllers.firstIndex(of: viewController) != nil else {
                return nil
            }
            
            return nil
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
    let ogaddhours: Int
    let ogaddminutes: Int
    
    let hourlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
    let minutelist = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    var body : some View {
        VStack(spacing: 15) {
            HStack {
                Text("\(self.subassignmentname)").font(.system(size: 18)).frame(width: UIScreen.main.bounds.size.width-100, alignment: .topLeading)
                
                Spacer()
                
                Button(action: {
                    self.offsetvar = UIScreen.main.bounds.size.width
                })
                { Image(systemName: "xmark.circle.fill").foregroundColor(.black) }
            }
            
            HStack {
                VStack {
                    Picker(selection: $addhours, label: Text("Hour")) {
                        ForEach(hourlist.indices) { hourindex in
                            Text(String(self.hourlist[hourindex]) + (self.hourlist[hourindex] == 1 ? " hour" : " hours"))
                         }
                     }.pickerStyle(WheelPickerStyle())
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
                            element.timeleft -= Int64(60*self.hourlist[self.addhours] + self.minutelist[self.addminutes])
//                            element.totaltime += Int64(60*self.hourlist[self.addhours] + self.minutelist[self.addminutes])
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
            
            HStack {
                Button(action: {
                    print(self.ogaddhours, self.ogaddminutes)
                })
                {
                    Text(" + Add More Time to Assignment")
                }
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
    
    @State var lastnthdayfromnow: Int
    @State var increased = true
    @Binding var uniformlistviewshows: Bool
    @State var stopupdating = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
 
    @State var timezoneOffset: Int = TimeZone.current.secondsFromGMT()
    
    init(verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, addhours: Binding<Int>, addminutes: Binding<Int>, uniformlistshows: Binding<Bool>) {
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._addhours = addhours
        self._addminutes = addminutes
        self._uniformlistviewshows = uniformlistshows
 
        self._lastnthdayfromnow = self._nthdayfromnow
        
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
        
        let lastmondaydate = Date(timeInterval: TimeInterval(86400 + timezoneOffset), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400+timezoneOffset+1), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400 + timezoneOffset+1), since: Date().startOfWeek!)
        
       // print(lastmondaydate.description)
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate))
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
        }
//        for i in 0...27 {
//            print(self.datesfromlastmonday[i], self.daytitlesfromlastmonday[i], self.datenumbersfromlastmonday[i])
//        }
    }
    
    func upcomingDisplayTime() -> String {
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
        let minuteval = Calendar.current
            .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(timezoneOffset)), to: subassignmentlist[0].startdatetime)
        .minute!
 
        if (minuteval > 720 ) {
            return "No Upcoming Subassignments"
        }
        if (minuteval < 60) {
            return "In " + String(minuteval) + " min: "
        }
        if (minuteval >= 60 && minuteval < 120) {
            return "In 1 h " + String(minuteval-60) + " min: "
        }
        return "In " + String(minuteval/60) + " h " + String(minuteval%60) + " min: "
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            if (!self.uniformlistviewshows)
            {
                VStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.daysoftheweekabr.indices) { dayofthweekabrindex in
                    Text(self.daysoftheweekabr[dayofthweekabrindex]).font(.system(size: (UIScreen.main.bounds.size.width / 25))).fontWeight(.light).frame(width: (UIScreen.main.bounds.size.width / 29) * 3)
                }
                }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
            
                    PageViewControllerWeeks(nthdayfromnow: $nthdayfromnow, viewControllers: [UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, datenumberindices: [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext))]).id(UUID()).frame(height: 70).padding(.bottom, -10)
            
            DummyPageViewControllerForDates(increased: self.$increased, stopupdating: self.$stopupdating, viewControllers: [UIHostingController(rootView: Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium))]).frame(height: 40)
            
            ZStack {
                if (subassignmentlist.count > 0) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color(subassignmentlist[0].color), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
                }
                else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("datenumberred"), Color("datenumberred")]), startPoint: .leading, endPoint: .trailing))
                }
                HStack {
                    VStack(alignment: .leading) {
                        if (subassignmentlist.count == 0) {
                            Text("No Upcoming Subassignments")
                        }
                        else if (self.upcomingDisplayTime() == "No Upcoming Subassignments") {
                            Text("No Upcoming Subassignments")
                        }
                        else {
                            Text("Next Upcoming:").fontWeight(.semibold).animation(.none)
                            Text(self.upcomingDisplayTime()).frame(width: self.subassignmentassignmentname == "" ? 200: 150, alignment: .topLeading).animation(.none)
                            
                            Text(subassignmentlist[0].assignmentname).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(height:40)
                            Text(timeformatter.string(from: subassignmentlist[0].startdatetime) + " - " + timeformatter.string(from: subassignmentlist[0].enddatetime)).font(.system(size: 15))
                        }
                    }.frame(width:self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60:150).animation(.none)
                    
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
                
            }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10)
            
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
                                            IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes, fixedHeight: false).padding(.top, CGFloat(subassignment.startdatetime.timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3).onTapGesture {
                                                self.subassignmentassignmentname = subassignment.assignmentname
                                                self.selectedColor = subassignment.color
                                                
//                                                for subassignment in self.subassignmentlist {
//                                                    print(subassignment.startdatetime.description)
//                                                }
                                                
 
                                            }
                                                //was +122 but had to subtract 2*60.35 to account for GMT + 2
                                            }
                                    }.animation(.spring())
                                }
                                Spacer()
                            }
                        }
                        
                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(timeIntervalSinceNow: TimeInterval(timezoneOffset)), toGranularity: .day)) {
                            HStack(spacing: 0) {
                                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                            }.padding(.top, CGFloat(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 120.7 - 1207)
                        }
                    }.animation(.spring())
                }
            }.onReceive(timer) { _ in
                //
            }
                }.transition(.move(edge: .leading)).animation(.spring())
        }
                
        else { //unifrom list view!!!! :)
            VStack {
                ScrollView {
                    HStack {
                        Text("Tasks").font(.largeTitle).fontWeight(.bold)
                        Spacer()
                    }.padding(.all, 10)
                    
                    ForEach(0 ..< daytitlesfromlastmonday.count) { daytitle in
                        HStack {
                            Spacer().frame(width: 10)
                            Text(self.daytitlesfromlastmonday[daytitle]).font(.system(size: 20)).foregroundColor(self.getsubassignmentsondate(dayIndex: daytitle) ? Color("blackwhite") : Color("blackwhite")).fontWeight(.semibold)
                            Spacer()
                        }.frame(width: UIScreen.main.bounds.size.width, height: 40).background(Color("add_overlay_bg")).padding(.bottom, 2)
                        
                        SubassignmentListView(daytitle: self.daytitlesfromlastmonday[daytitle], verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes, daytitlesfromlastmonday: self.daytitlesfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).animation(.spring())
                        
                    }.animation(.spring())
    //                ForEach(subassignmentlist) {
    //                    subassignment in
    //                    IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes).onTapGesture {
    //                        self.subassignmentassignmentname = subassignment.assignmentname
    //                        self.selectedColor = subassignment.color
    //
    //                    }
    //                }
                }.animation(.spring())
            }.transition(.move(edge: .leading)).animation(.spring())
        }
        }.transition(.move(edge: .leading)).animation(.easeInOut)
    }
    
    func getsubassignmentsondate(dayIndex: Int) -> Bool {
        for subassignment in subassignmentlist {
            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.shortdateformatter.string(from: self.datesfromlastmonday[dayIndex])) {
                    return true  //was +122 but had to subtract 2*60.35 to account for GMT + 2
            }
        }
        
        return false
    }
}
 
struct SubassignmentListView: View {
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    var daytitle: String
    var daytitlesfromlastmonday: [String]
    var datesfromlastmonday: [Date]
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    @Binding var addhours: Int
    @Binding var addminutes: Int
    var shortdateformatter: DateFormatter
    
    init(daytitle: String,  verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, addhours: Binding<Int>, addminutes: Binding<Int>, daytitlesfromlastmonday: [String], datesfromlastmonday: [Date]) {
        self.daytitle = daytitle
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._addhours = addhours
        self._addminutes = addminutes
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.daytitlesfromlastmonday = daytitlesfromlastmonday
        self.datesfromlastmonday = datesfromlastmonday
    }
    
    func getcurrentdatestring() -> String {
        for (index, value) in daytitlesfromlastmonday.enumerated() {
            if (value == daytitle) {
                return self.shortdateformatter.string(from: self.datesfromlastmonday[index])
            }
        }
        
        return ""
    }
    
    var body: some View {
      //  ScrollView {
            ForEach(subassignmentlist) {
                subassignment in
                if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring()) {
                    IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes, fixedHeight: true)                        //was +122 but had to subtract 2*60.35 to account for GMT + 2
                }
                
            }.animation(.spring())
    //    }.animation(.spring())
    }
    
    func computesubassignmentlength(subassignment: Subassignmentnew) -> Int {
        let diffComponents = Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime)
        return diffComponents.minute!
    }
}

struct UpcomingSubassignmentProgressBar: View {
    @ObservedObject var assignment: Assignment
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).frame(width:  150, height: 10)
            HStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).frame(width:  CGFloat(CGFloat(assignment.progress)/100*150), height:10, alignment: .leading).animation(.spring())
                if (assignment.progress != 100) {
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
    var fixedHeight: Bool
    
    var subassignmentlength: Int
 
    var subassignment: Subassignmentnew
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    @Binding var addhours: Int
    @Binding var addminutes: Int
    let screenval = -UIScreen.main.bounds.size.width
    
    init(subassignment2: Subassignmentnew, verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, addhours: Binding<Int>, addminutes: Binding<Int>, fixedHeight: Bool) {
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
        self.fixedHeight = fixedHeight
        //print(subassignmentlength)
    }
        
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +    CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: self.fixedHeight ? UIScreen.main.bounds.size.width - 10 + self.dragoffset.width : UIScreen.main.bounds.size.width-30+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()
//                            if (self.dragoffset.width < -110) {
//                                Text("Complete").foregroundColor(Color.white).frame(width:self.fixedHeight ? 100 : 120)
//                            }
//                            else {
                                Text("Complete").foregroundColor(Color.white).frame(width:self.dragoffset.width < -110 ? self.fixedHeight ? 100 : 120 : 120).offset(x: self.dragoffset.width < -110 ? 0: self.fixedHeight ? self.dragoffset.width + 120 : self.dragoffset.width + 110)
              //              }
                        }
                    }
                }
                if (isDraggedleft) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +  CGFloat(Double(((subassignmentlength-60)/60))*60.35)).offset(x: self.fixedHeight ? screenval+10+self.dragoffset.width : -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
                        }
                        
                        HStack {
//                            if (self.dragoffset.width > 150) {
//                                Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: -120)
//                                Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: -160)
//                            }
//                            else {
                            Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -120 : -150 : self.fixedHeight ? self.dragoffset.width - 270 : self.dragoffset.width-300)
                            Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -160 : -190 : self.fixedHeight ? self.dragoffset.width - 310 : self.dragoffset.width-340)
                 //           }
                        }
                    }
                }
            }
            
            VStack {
                Text(self.name).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                if (!fixedHeight)
                {
                    Text(self.starttime + " - " + self.endtime).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                }
                if (fixedHeight)
                {
                    Spacer().frame(height: 10)
                    Text(String(self.subassignmentlength/60) + " hours " + String(self.subassignmentlength % 60) + " minutes").frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                }
                Spacer()
//                Text("Due Date: " + self.duedate).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
               // Text(self.actualstartdatetime.description)
//                Text(self.actualenddatetime.description)
            }.frame(height: fixedHeight ? 50 : 38 + CGFloat(Double(((subassignmentlength-60)/60))*60.35)).padding(12).background(Color(color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 25, coordinateSpace: .local)
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
                                }
                            }
                            
//                            for (index, element) in self.subassignmentlist.enumerated() {
//                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
//                                    self.managedObjectContext.delete(self.subassignmentlist[index])
//                                }
//                            }
                            
//                            do {
//                                try self.managedObjectContext.save()
//                                print("Subassignment time added")
//                            } catch {
//                                print(error.localizedDescription)
//                            }
                            
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
                                            if (classity.originalname == element.subject) {
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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var changingDate: DisplayedDate
 
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false
    @State var noAssignmentsAlert = false
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
 
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.name, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @State var noClassesAlert = false
 
    
    @State var noCompletedAlert = false
    //completed true and grade != 0
    @State var verticaloffset: CGFloat = UIScreen.main.bounds.height
    @State var subassignmentname = "SubAssignmentNameBlank"
    @State var addhours = 0
    @State var addminutes = 0
    @State var uniformlistshows: Bool
    
    init() {
        let defaults = UserDefaults.standard
        let viewtype = defaults.object(forKey: "savedtoggleview") as? Bool ?? false
        _uniformlistshows = State(initialValue: viewtype)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: UIScreen.main.bounds.size.width / 3.7) {
                    Button(action: {print("settings button clicked")}) {
                        Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                    }
                    
                    Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 5)
                    Button(action: {
                        withAnimation(.spring())
                        {
                            self.uniformlistshows.toggle()
                        }
                        
                    }) {
                        Image(systemName: self.uniformlistshows ? "square.righthalf.fill" : "square.lefthalf.fill").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                    }
                }.padding(.top, -5)
                
                HomeBodyView(verticaloffset: $verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes, uniformlistshows: self.$uniformlistshows).environmentObject(self.changingDate)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("fifteen")).frame(width: 70, height: 70).padding(20)
                        Button(action: {
                            self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
    //                        self.scalevalue = self.scalevalue == 1.5 ? 1 : 1.5
    //                        self.ocolor = self.ocolor == Color.blue ? Color.green : Color.blue
 
                            }) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).contextMenu{
                                                            Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                                                                Text("Assignment")
                                                                Image(systemName: "paperclip")
                                                            }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                                                                Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                                                            }
                                                            Button(action: {self.NewClassPresenting.toggle()}) {
                                                                Text("Class")
                                                                Image(systemName: "list.bullet")
                                                            }.sheet(isPresented: $NewClassPresenting, content: {
                                                                NewClassModalView(NewClassPresenting: self.$NewClassPresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                                //                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                //                                Text("Occupied Time")
                                //                                Image(systemName: "clock.fill")
                                //                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                                                            Button(action: {self.NewFreetimePresenting.toggle()}) {
                                                                Text("Free Time")
                                                                Image(systemName: "clock")
                                                            }.sheet(isPresented: $NewFreetimePresenting, content: { NewFreetimeModalView(NewFreetimePresenting: self.$NewFreetimePresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                                                            Button(action: {self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()}) {
                                                                Text("Grade")
                                                                Image(systemName: "percent")
                                                            }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noAssignmentsAlert) {
                                                                Alert(title: Text("No Assignments Completed"), message: Text("Complete an Assignment First"))
                                                            }
                                                        }.frame(width: 70, height: 70).padding(20).overlay(
                                ZStack {
                                    //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                    Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                                }
                            )
                        }
                    }
                    
                
 
                }
            }
            
            VStack {
                Spacer()
                
                SubassignmentAddTimeAction(offsetvar: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes, ogaddhours: self.addhours, ogaddminutes: self.addminutes).offset(y: self.verticaloffset).animation(.spring())
            }.background((self.verticaloffset <= 110 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all))
        }.onDisappear() {
            let defaults = UserDefaults.standard
 
            defaults.set(self.uniformlistshows, forKey: "savedtoggleview")
        }
    }
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0)
            {
                return true;
            }
        }
        return false
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
        return HomeView().environment(\.managedObjectContext, context).environmentObject(DisplayedDate())
    }
}
