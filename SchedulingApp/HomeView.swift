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
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    @Binding var nthdayfromnow: Int
    @Binding var lastnthdayfromnow: Int
    @Binding var increased: Bool
    @Binding var stopupdating: Bool
    
    @Binding var NewAssignmentPresenting: Bool
    
    @State var noClassesAlert = false
    var refreshview: Bool = false
    let datenumberindices: [Int]
    let datenumbersfromlastmonday: [String]
    let datesfromlastmonday: [Date]
    
    func getassignmentsbydate(index: Int) -> [String] {
        var ans: [String] = []
     //  print("Index: " + String(index))
        
        for assignment in assignmentlist {
            //refreshview.toggle()
           // let diff = Calendar.current.dateComponents([.day], from: self.datesfromlastmonday[self.datenumberindices[index]], to:
            //assignment.duedate).day
            if (assignment.completed == false)
            {
                let diff = Calendar.current.isDate(Date(timeInterval: 0, since: self.datesfromlastmonday[self.datenumberindices[index]]), equalTo: Date(timeInterval: 0, since: assignment.duedate), toGranularity: .day)
             //   print(self.datesfromlastmonday[self.datenumberindices[index]], assignment.duedate.description)
                if (diff == true)
                {
                    //print(assignment.name)
                    ans.append(assignment.color)
                }
                    
            }
            //print(assignment.name)
        }
 
        //print(ans.count)
        return ans
    }
    
    func getassignmentsbydateindex(index: Int, index2: Int) -> String {
        //return getassignmentsbydate(index:index).count
        if (index2 < self.getassignmentsbydate(index: index).count)
        {
            return self.getassignmentsbydate(index: index)[index2]
        }
    
    //    print("one")
        return "zero"
        
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
        if (length == 4) {
            return 7*CGFloat(assignmentsindex)-14
        }
        if (length == 5) {
            return 7*CGFloat(assignmentsindex)-17.5
        }
         
        return CGFloat(CGFloat(assignmentsindex)/CGFloat(length) * 20 - 10)
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("datenumberred")).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).opacity(self.datenumberindices[index] == self.nthdayfromnow ? 1 : 0)
                          //  Circle().fill(Color("one")).frame(width: 5, height: 5)
 
                            Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(self.datenumberindices[index] == Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day! ? .bold : .regular)
                        }.contextMenu {
                            Button(action: {self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()}) {
                                Text("Assignment")
                                Image(systemName: "paperclip")
                            }.alert(isPresented: self.$noClassesAlert) {
                                Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                            }
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
                        }
                        ZStack {
                            ForEach(self.getassignmentsbydate(index: index).indices) { index2 in
//                                if (Int(index2) < self.getlenofassignmentsbydate(index: index))
//                                {
                                if (self.getassignmentsbydateindex(index: index, index2: index2) == "zero")
                                {
                                    
                                }
                                else
                                {
                                    Circle().fill(Color(self.getassignmentsbydateindex(index: index, index2: index2))).frame(width: 5, height:  5).offset(x: self.getoffsetfromindex(assignmentsindex: index2, index: index))
                                }
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

struct SubassignmentAddTimeActionBody: View {
    @Binding var subassignmentname: String
    @Binding var subassignmentlength: Int
    @Binding var subassignmentcolor: String
    @Binding var subassignmentstarttimetext: String
    @Binding var subassignmentendtimetext: String
    @Binding var subassignmentdatetext: String
    @Binding var subassignmentindex: Int
    @Binding var subassignmentcompletionpercentage: Double
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(self.subassignmentcolor)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 0.6)
                )
                
                Spacer().frame(width: 15)
                
                VStack {
                    HStack {
                        Text(self.subassignmentname).font(.system(size: 17)).fontWeight(.medium)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 6)
                    
                    HStack {
                        Text(self.subassignmentstarttimetext + " - " + self.subassignmentendtimetext).font(.system(size: 15)).fontWeight(.light)
                        
                        Spacer()
                        
                        Text(self.subassignmentdatetext).font(.system(size: 15)).fontWeight(.light)
                        
                        Spacer().frame(width: 15)
                    }
                }
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer().frame(height: 15)
            
            HStack {
                Text("How much of the task did you complete?").font(.system(size: 16)).fontWeight(.light)
                
                Spacer()
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Section {
                Slider(value: $subassignmentcompletionpercentage, in: 0...100)
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Text("\(subassignmentcompletionpercentage.rounded(.down), specifier: "%.0f")%")
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
    @Binding var subassignmentlength: Int
    //remember to work as double for division operations and stuff
    @Binding var subassignmentcolor: String
    @Binding var subassignmentstarttimetext: String
    @Binding var subassignmentendtimetext: String
    @Binding var subassignmentdatetext: String
    @Binding var subassignmentindex: Int
    @Binding var subassignmentcompletionpercentage: Double
    
    var body : some View {
        VStack {
            HStack {
                Text("Add Time to Assignment").font(.system(size: 14)).fontWeight(.light)
                Spacer()
                Button(action: {
                    self.offsetvar = UIScreen.main.bounds.size.width
                }, label: {
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.black)
                })
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer()
            
            SubassignmentAddTimeActionBody(subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage)
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 0.4)
            
            Button(action: {
                self.managedObjectContext.delete(self.subassignmentlist[self.subassignmentindex])
                self.offsetvar = UIScreen.main.bounds.size.width
                
                for (_, element) in self.assignmentlist.enumerated() {
                    if (element.name == self.subassignmentname) {
                        let minutescompleted = (self.subassignmentcompletionpercentage / 100) * Double(self.subassignmentlength)
                        let minutescompletedroundeddown = Int(minutescompleted / 5) * 5
                        element.timeleft -= Int64(minutescompletedroundeddown)
                        element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                    }
                }
                    
                do {
                    try self.managedObjectContext.save()
                    print("Subassignment time added")
                } catch {
                    print(error.localizedDescription)
                }
                
            }, label: {
                Text("Done").font(.system(size: 17)).fontWeight(.semibold)
            }).padding(.all, 8).padding(.bottom, -3)
        }.padding(.all, 15).frame(maxHeight: 270).background(Color("very_light_gray")).cornerRadius(18).padding(.all, 15)
    }
}
 

struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var changingDate: DisplayedDate
 
 
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.completed, ascending: true), NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
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
    
    @State var nthweekfromnow: Int = 0
    
    @State var selecteddaytitle: Int = 0
    
    var hourformatter: DateFormatter
    var minuteformatter: DateFormatter
    var shortdateformatter: DateFormatter
    @State var subassignmentassignmentname: String = ""
    
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    @Binding var subassignmentlength: Int
    @Binding var subassignmentcolor: String
    @Binding var subassignmentstarttimetext: String
    @Binding var subassignmentendtimetext: String
    @Binding var subassignmentdatetext: String
    @Binding var subassignmentindex: Int
    @Binding var subassignmentcompletionpercentage: Double
    
    @State var selectedColor: String = "one"
    
    @State var lastnthdayfromnow: Int
    @State var increased = true
    @Binding var uniformlistviewshows: Bool
    @State var stopupdating = false
    @Binding var NewAssignmentPresenting: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
 
    @State var timezoneOffset: Int = TimeZone.current.secondsFromGMT()
    @State var showeditassignment: Bool = false
    @ObservedObject var sheetnavigator: SheetNavigatorEditClass = SheetNavigatorEditClass()
    
    init(verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, subassignmentlength: Binding<Int>, subassignmentcolor: Binding<String>, subassignmentstarttimetext: Binding<String>, subassignmentendtimetext: Binding<String>, subassignmentdatetext: Binding<String>, subassignmentindex: Binding<Int>, subassignmentcompletionpercentage: Binding<Double>, uniformlistshows: Binding<Bool>, NewAssignmentPresenting2: Binding<Bool>) {
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._subassignmentlength = subassignmentlength
        self._subassignmentcolor = subassignmentcolor
        self._subassignmentstarttimetext = subassignmentstarttimetext
        self._subassignmentendtimetext = subassignmentendtimetext
        self._subassignmentdatetext = subassignmentdatetext
        self._subassignmentindex = subassignmentindex
        self._subassignmentcompletionpercentage = subassignmentcompletionpercentage
        
        self._uniformlistviewshows = uniformlistshows
        self._NewAssignmentPresenting = NewAssignmentPresenting2
 
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
        //timeformatter.timeZone = TimeZone(secondsFromGMT: 0)
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
     //   shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
       // self._selecteddaytitle = State(initialValue: nthdayfromnow)
        self.selectedColor  = "one"
        
        let lastmondaydate = Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400+1), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400 + 1), since: Date().startOfWeek!)
        
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
            .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: subassignmentlist[self.getsubassignment()].startdatetime)
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
    
    func getsubassignment() -> Int {
        let timezoneOffset =  TimeZone.current.secondsFromGMT()

        var minuteval: Int = 0
        for (index, _) in subassignmentlist.enumerated() {
            
            minuteval = Calendar.current
                .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: subassignmentlist[index].startdatetime)
            .minute!
            //print(minuteval)
            if (minuteval > 0)
            {
                return index
            }
            
        }
        return -1
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getassignmentindex() -> Int {
        for (index, assignment) in assignmentlist.enumerated() {
            if (assignment.name == sheetnavigator.selectededitassignment)
            {
                return index
            }
        }
        return 0
    }
    
    var body: some View {
        VStack {
            if (!self.uniformlistviewshows) {
                VStack {
                    HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                        ForEach(self.daysoftheweekabr.indices) { dayofthweekabrindex in
                            Text(self.daysoftheweekabr[dayofthweekabrindex]).font(.system(size: (UIScreen.main.bounds.size.width / 25))).fontWeight(.light).frame(width: (UIScreen.main.bounds.size.width / 29) * 3)
                        }
                    }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))
                  //  SpecialView()
                    if #available(iOS 14.0, *) {
                        TabView() {
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(0)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(1)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices:  [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(2)
                            WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext).tag(3)
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 70)
                    } else {
                        PageViewControllerWeeks(nthdayfromnow: $nthdayfromnow, viewControllers: [UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [0, 1, 2, 3, 4, 5, 6], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating,NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [7, 8, 9, 10, 11, 12, 13], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating,NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [14, 15, 16, 17, 18, 19, 20], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext)), UIHostingController(rootView: WeeklyBlockView(nthdayfromnow: self.$nthdayfromnow, lastnthdayfromnow: self.$lastnthdayfromnow, increased: self.$increased, stopupdating: self.$stopupdating, NewAssignmentPresenting: $NewAssignmentPresenting, datenumberindices: [21, 22, 23, 24, 25, 26, 27], datenumbersfromlastmonday: self.datenumbersfromlastmonday, datesfromlastmonday: self.datesfromlastmonday).environment(\.managedObjectContext, self.managedObjectContext))]).id(UUID()).frame(height: 70).padding(.bottom, -10)
                    }

                    if #available(iOS 14.0, *) {
                        TabView(selection: self.$nthdayfromnow) {
                            ForEach(daytitlesfromlastmonday.indices) {
                                index in
                                Text(daytitlesfromlastmonday[index]).font(.title).fontWeight(.medium).tag(index).frame(height: 40)
                            }
                            
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 40).animation(.spring())
                        
                    } else {
                        DummyPageViewControllerForDates(increased: self.$increased, stopupdating: self.$stopupdating, viewControllers: [UIHostingController(rootView: Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium))]).frame(width: UIScreen.main.bounds.size.width-40, height: 40)
                    }
            
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
                            Text("No Upcoming Tasks").font(.system(size: 22))
                        }
                        else if (self.getsubassignment() == -1 || self.upcomingDisplayTime() == "No Upcoming Subassignments") {
                            Text("No Upcoming Tasks").font(.system(size: 22))
                        }
                        else {
                            Text("Next Upcoming:").fontWeight(.semibold).animation(.none)
                            Text(self.upcomingDisplayTime()).frame(width: self.subassignmentassignmentname == "" ? 200: 150, height:30, alignment: .topLeading).animation(.none)

                            Text(subassignmentlist[self.getsubassignment()].assignmentname).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(height:20)
                            Text(timeformatter.string(from: subassignmentlist[self.getsubassignment()].startdatetime) + " - " + timeformatter.string(from: subassignmentlist[self.getsubassignment()].enddatetime)).font(.system(size: 15)).frame(height:20)
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
                                    Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 12)).frame(height:15)
                                    Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                    UpcomingSubassignmentProgressBar(assignment: assignment).frame(height:10)
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
                                            IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage, fixedHeight: false, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: subassignment.startdatetime), to: subassignment.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3).onTapGesture {
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

                        if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(timeIntervalSinceNow: TimeInterval(0)), toGranularity: .day)) {
                            HStack(spacing: 0) {
                                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                            }.padding(.top, CGFloat(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: 86400)/3600 * 120.7 - 1207)
                        }
                    }//.animation(.spring())
                }
            }.onReceive(timer) { _ in
                //
            }
                }//.transition(.move(edge: .leading)).animation(.spring())
        }
        else {
            //Spacer().frame(height:40)
            VStack {
                HStack {
                    Text("Tasks").font(.largeTitle).bold()
                    Spacer()
                }.padding(.all, 10).padding(.leading, 10)
                
                ZStack {
                    if (subassignmentlist.count > 0) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color(subassignmentlist[0].color), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
                    }

                    else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("datenumberred"), Color("datenumberred")]), startPoint: .leading, endPoint: .trailing))
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center)
                            {
                                ForEach(self.assignmentlist) { assignment in
                                    if (assignment.name == self.subassignmentassignmentname) {
                                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 80, alignment: .center)//.offset(y: 5)

                                    }
                                 }
                                if (self.subassignmentassignmentname == "")
                                {
                                    Text("No Task Selected").font(.system(size: 22)).multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width-60, height: 80, alignment: .center)
                                }
                            }
                        }.frame(width:self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60:150).animation(.none)

                        if self.subassignmentassignmentname != "" {
                            Spacer().frame(width: 10)
                            Divider().frame(width: 1).background(Color.black)
                            Spacer().frame(width: 10)
                            VStack(alignment: .leading) {
                                ForEach(self.assignmentlist) { assignment in
                                    if (assignment.name == self.subassignmentassignmentname) {
                                      //  Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 40, alignment: .topLeading)

                                        Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 15)).fontWeight(.bold).frame(height:40)
                                        Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                        Text("Time Left: " + String(assignment.timeleft) + " mintues").font(.system(size: 12)).frame(height: 15)
                                        UpcomingSubassignmentProgressBar(assignment: assignment).frame(height:10)
                                    }
                                }
                            }.frame(width: 150)
                        }
                        
                    }.padding(10)
                }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10)
                ScrollView {


                ForEach(0 ..< daytitlesfromlastmonday.count) { daytitle in
                    if (Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day! <= daytitle)
                    {
                        HStack {
                            Spacer().frame(width: 10)
                            Text(self.daytitlesfromlastmonday[daytitle]).font(.system(size: 20)).foregroundColor(daytitle == Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day! ? Color.blue : Color("blackwhite")).fontWeight(.bold)
                            Spacer()
                        }.frame(width: UIScreen.main.bounds.size.width, height: 40).background(Color("add_overlay_bg"))
                        SubassignmentListView(daytitle: self.daytitlesfromlastmonday[daytitle], verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage, daytitlesfromlastmonday: self.daytitlesfromlastmonday, datesfromlastmonday: self.datesfromlastmonday, subassignmentassignmentname: self.$subassignmentassignmentname, selectedcolor: self.$selectedColor, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment).animation(.spring())
                    }
                }.animation(.spring())
//                ForEach(subassignmentlist) {
//                    subassignment in
//                    IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, addhours: self.$addhours, addminutes: self.$addminutes).onTapGesture {
//                        self.subassignmentassignmentname = subassignment.assignmentname
//                        self.selectedColor = subassignment.color
//
//                    }
//                }
            }
            }//.transition(.move(edge: .leading)).animation(.spring())
        }
        }.sheet(isPresented: $showeditassignment, content: {
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext)})
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
    @Binding var subassignmentlength: Int
    @Binding var subassignmentcolor: String
    @Binding var subassignmentstarttimetext: String
    @Binding var subassignmentendtimetext: String
    @Binding var subassignmentdatetext: String
    @Binding var subassignmentindex: Int
    @Binding var subassignmentcompletionpercentage: Double
    
    @Binding var subassignmentassignmentname: String
    @Binding var selectedcolor: String
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    var shortdateformatter: DateFormatter
    
    init(daytitle: String,  verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, subassignmentlength: Binding<Int>, subassignmentcolor: Binding<String>, subassignmentstarttimetext: Binding<String>, subassignmentendtimetext: Binding<String>, subassignmentdatetext: Binding<String>, subassignmentindex: Binding<Int>, subassignmentcompletionpercentage: Binding<Double>, daytitlesfromlastmonday: [String], datesfromlastmonday: [Date], subassignmentassignmentname: Binding<String>, selectedcolor: Binding<String>, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>)
    {
        self.daytitle = daytitle
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._subassignmentlength = subassignmentlength
        self._subassignmentcolor = subassignmentcolor
        self._subassignmentstarttimetext = subassignmentstarttimetext
        self._subassignmentendtimetext = subassignmentendtimetext
        self._subassignmentdatetext = subassignmentdatetext
        self._subassignmentindex = subassignmentindex
        self._subassignmentcompletionpercentage = subassignmentcompletionpercentage
        
        self._subassignmentassignmentname = subassignmentassignmentname
        self._selectedcolor = selectedcolor
        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
       // shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.daytitlesfromlastmonday = daytitlesfromlastmonday
        self.datesfromlastmonday = datesfromlastmonday
        
    }
    
    func getcurrentdatestring() -> String {
        for (index, value) in daytitlesfromlastmonday.enumerated() {
            if (value == daytitle)
            {
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
                    IndividualSubassignmentView(subassignment2: subassignment, verticaloffset: self.$verticaloffset, subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment).onTapGesture {
                        selectedcolor = subassignment.color
                        subassignmentassignmentname = subassignment.assignmentname
                    }                        //was +122 but had to subtract 2*60.35 to account for GMT + 2
                }
                
            }.animation(.spring())
    //    }.animation(.spring())
    }
    func computesubassignmentlength(subassignment: Subassignmentnew) -> Int
    {
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
    
    var subassignmentlength_actual: Int
 
    var subassignment: Subassignmentnew
    @Binding var verticaloffset: CGFloat
    @Binding var subassignmentname: String
    @Binding var subassignmentlength: Int
    @Binding var subassignmentcolor: String
    @Binding var subassignmentstarttimetext: String
    @Binding var subassignmentendtimetext: String
    @Binding var subassignmentdatetext: String
    @Binding var subassignmentindex: Int
    @Binding var subassignmentcompletionpercentage: Double
    
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    
    let screenval = -UIScreen.main.bounds.size.width
    
    var shortdateformatter: DateFormatter
    
    init(subassignment2: Subassignmentnew, verticaloffset: Binding<CGFloat>, subassignmentname: Binding<String>, subassignmentlength: Binding<Int>, subassignmentcolor: Binding<String>, subassignmentstarttimetext: Binding<String>, subassignmentendtimetext: Binding<String>, subassignmentdatetext: Binding<String>, subassignmentindex: Binding<Int>, subassignmentcompletionpercentage: Binding<Double>, fixedHeight: Bool, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>) {
        self._verticaloffset = verticaloffset
        self._subassignmentname = subassignmentname
        self._subassignmentlength = subassignmentlength
        self._subassignmentcolor = subassignmentcolor
        self._subassignmentstarttimetext = subassignmentstarttimetext
        self._subassignmentendtimetext = subassignmentendtimetext
        self._subassignmentdatetext = subassignmentdatetext
        self._subassignmentindex = subassignmentindex
        self._subassignmentcompletionpercentage = subassignmentcompletionpercentage
        
        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
      //  formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        print(subassignment2.startdatetime.description, self.starttime)
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
        subassignmentlength_actual = diffComponents.minute!
        subassignment = subassignment2
        self.fixedHeight = fixedHeight
        //print(subassignmentlength_actual)
        
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
     //   shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
        
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +    CGFloat(Double(((Double(subassignmentlength_actual)-60)/60))*60.35)).offset(x: self.fixedHeight ? UIScreen.main.bounds.size.width - 10 + self.dragoffset.width : UIScreen.main.bounds.size.width-30+self.dragoffset.width)
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
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +  CGFloat(Double(((Double(subassignmentlength_actual)-60)/60))*60.35)).offset(x: self.fixedHeight ? screenval+10+self.dragoffset.width : -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
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
                    Text(String(self.subassignmentlength_actual/60) + " hours " + String(self.subassignmentlength_actual % 60) + " minutes").frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                }
                Spacer()
//                Text("Due Date: " + self.duedate).frame(width: UIScreen.main.bounds.size.width-80, alignment: .topLeading)
               // Text(self.actualstartdatetime.description)
//                Text(self.actualenddatetime.description)
            }.frame(height: fixedHeight ? 50 : 38 + CGFloat(Double(((Double(subassignmentlength_actual)-60)/60))*60.35)).padding(12).background(Color(color)).cornerRadius(20).contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).offset(x: self.dragoffset.width).contextMenu {
                Button(action:{
                    self.showeditassignment = true
                    self.selectededitassignment = subassignment.assignmentname
                })
                {
                 //   HStack {
                        Text("Edit Assignment")
                        Image(systemName: "pencil.circle")
                   // }
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
                    //self.isDragged = true
 
                    if (self.dragoffset.width < 0) {
                        self.isDraggedleft = false
                        self.isDragged = true
                        self.incompleted = false
                    }
                    else if (self.dragoffset.width > 0) {
                        self.isDragged = false
                        self.isDraggedleft = true
                        self.deleted = false
                    }
                                        
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 3/4) {
                        self.deleted = true
                    }
                    else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 3/4) {
                        self.incompleted = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                        self.dragoffset = .zero
                    }
                }
                .onEnded { value in
                    self.dragoffset = .zero
                    
                    //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
//                        self.isDragged = false
//                        self.isDraggedleft = false
                   // }
                   
                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
//                            self.incompletedonce = false
                            print("incompleted")
                            
                            self.verticaloffset = 0
                            self.subassignmentname = self.name
                            self.subassignmentlength = self.subassignmentlength_actual
                            self.subassignmentcolor = self.color
                            self.subassignmentstarttimetext = self.starttime
                            self.subassignmentendtimetext = self.endtime
                            self.subassignmentdatetext = self.shortdateformatter.string(from: self.actualstartdatetime)
                            self.subassignmentcompletionpercentage = 0
                            
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    self.subassignmentindex = index
                                }
                            }
                        }
                    }
                        
                    else if (self.deleted == true) {
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    let minutes = self.subassignmentlength_actual
                                    element.timeleft -= Int64(minutes)
                                    withAnimation(.spring())
                                    {
                                        if (element.totaltime != 0)
                                        {
                                            element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                        }
                                        else
                                        {
                                            element.progress = 100
                                        }
                                        
                                    }
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
 

enum ModalView {
    case grade
    case freetime
    case assignment
    case classity
    case none
}

class SheetNavigator: ObservableObject {
    @Published var modalView: ModalView = .none
    @Published var alertView: AlertView = .none
}
enum AlertView {
    case none
    case noclass
    case noassignment
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
    @State var subassignmentlength = 0
    @State var subassignmentcolor = "one"
    @State var subassignmentstarttimetext = "aa:bb"
    @State var subassignmentendtimetext = "cc:dd"
    @State var subassignmentdatetext = "dd/mm/yy"
    @State var subassignmentindex = 0
    @State var subassignmentcompletionpercentage: Double = 0
    
    @State var uniformlistshows: Bool
    @State var showingSettingsView = false
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    init() {
        let defaults = UserDefaults.standard
        let viewtype = defaults.object(forKey: "savedtoggleview") as? Bool ?? false
        _uniformlistshows = State(initialValue: viewtype)
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        
        if (self.sheetNavigator.modalView == .freetime)
        {
            
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .classity)
        {
            NewClassModalView(NewClassPresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else if (self.sheetNavigator.modalView == .grade)
        {
            NewGradeModalView(NewGradePresenting: self.$NewSheetPresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)
        }
        else
        {
            Button(action: {
                print(self.modalView)
            }) {
                Text("click me")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ZStack {
                    
                    NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                        { EmptyView() }
                    HomeBodyView(verticaloffset: $verticaloffset, subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage, uniformlistshows: self.$uniformlistshows, NewAssignmentPresenting2: $NewAssignmentPresenting).environmentObject(self.changingDate).padding(.top, -40)               // }
                    
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                // RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("fifteen")).frame(width: 70, height: 70).opacity(1).padding(20)
                                Button(action: {
                                    if (classlist.count > 0)
                                    {
                                        self.sheetNavigator.modalView = .assignment
                                        print(self.modalView)
                                        self.NewSheetPresenting = true
                                       // self.NewGradePresenting = true
                                    }
                                    else
                                    {
                                        self.sheetNavigator.alertView = .noclass
                                        self.NewAlertPresenting = true
                                    }
                                    
                                }) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).opacity(1).padding(20).overlay(
                                        ZStack {
                                            //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                            Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30)
                                        }
                                    )
                                }.buttonStyle(PlainButtonStyle()).contextMenu{
                                    Button(action: {
                                        if (classlist.count > 0)
                                        {
                                            self.sheetNavigator.modalView = .assignment
                                            self.NewSheetPresenting = true
                                            self.NewAssignmentPresenting = true
                                        }
                                        else
                                        {
                                            self.sheetNavigator.alertView = .noclass
                                            self.NewAlertPresenting = true
                                        }
                                    }) {
                                        Text("Assignment")
                                        Image(systemName: "paperclip")
                                    }
                                    Button(action: {
                                        self.sheetNavigator.modalView = .classity
                                        self.NewSheetPresenting = true
                                        self.NewClassPresenting = true
                                    }) {
                                        Text("Class")
                                        Image(systemName: "list.bullet")
                                    }
                                    //                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                    //                                Text("Occupied Time")
                                    //                                Image(systemName: "clock.fill")
                                    //                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: { NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                                    Button(action: {
                                        self.sheetNavigator.modalView = .freetime
                                        print(self.modalView)
                                        self.NewSheetPresenting = true
                                    }) {
                                        Text("Free Time")
                                        Image(systemName: "clock")
                                    }
                                    Button(action: {
                                        
                                        if (self.getcompletedAssignments())
                                        {
                                            self.sheetNavigator.modalView = .grade
                                            self.NewSheetPresenting = true
                                        }
                                        else
                                        {
                                            self.sheetNavigator.alertView = .noassignment
                                            self.NewAlertPresenting = true
                                        }
                                        //  self.getcompletedAssignments() ? self.NewGradePresenting.toggle() : self.noAssignmentsAlert.toggle()
                                        
                                    }) {
                                        Text("Grade")
                                        Image(systemName: "percent")
                                    }
                                    
                                }//.sheet(isPresented: $NewSheetPresenting, content: sheetContent)
                            }.sheet(isPresented: $NewSheetPresenting, content: sheetContent ).alert(isPresented: $NewAlertPresenting) {
                                Alert(title: self.sheetNavigator.alertView == .noassignment ? Text("No Assignments Completed") : Text("No Classes Added"), message: self.sheetNavigator.alertView == .noassignment ? Text("Complete an Assignment First") : Text("Add a Class First"))
                            }
                            
                            
                            
                            
                        }
                    }
                    //                .sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noClassesAlert) {
                    //                    Alert(title: Text("No Classes Added"), message: Text("Add a Class First"))
                    //                }
                    //                .sheet(isPresented: $NewClassPresenting, content: {
                    //                            NewClassModalView(NewClassPresenting: self.$NewClassPresenting).environment(\.managedObjectContext, self.managedObjectContext)})
                    
                    
                    //                .sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView(NewGradePresenting: self.$NewGradePresenting, classfilter: -1).environment(\.managedObjectContext, self.managedObjectContext)}).alert(isPresented: $noAssignmentsAlert) {
                    //                    Alert(title: Text("No Assignments Completed"), message: Text("Complete an Assignment First"))
                    //                }
                    
                    //            NavigationView {
                    //                NavigationLink(destination:
                    //                    ZStack {
                    //                       // Rectangle().fill(self.colorScheme == .light ? Color.white : Color.black).frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    //                        SettingsView()
                    //                    }
                    //
                    //
                    //                    , isActive: self.$showingSettingsView)
                    //                { Text("") }
                    //            }
                    VStack {
                        Spacer()
                         
                        SubassignmentAddTimeAction(offsetvar: self.$verticaloffset, subassignmentname: self.$subassignmentname, subassignmentlength: self.$subassignmentlength, subassignmentcolor: self.$subassignmentcolor, subassignmentstarttimetext: self.$subassignmentstarttimetext, subassignmentendtimetext: self.$subassignmentendtimetext, subassignmentdatetext: self.$subassignmentdatetext, subassignmentindex: self.$subassignmentindex, subassignmentcompletionpercentage: self.$subassignmentcompletionpercentage).offset(y: self.verticaloffset).animation(.spring())
                    }.frame(width: UIScreen.main.bounds.size.width).background((self.verticaloffset <= 110 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all))
                }
                            .navigationBarItems(leading:
                            //                VStack {
                            //                    Spacer().frame(height:10)
                                                HStack(spacing: UIScreen.main.bounds.size.width / 4.5) {
                                                    Button(action: {self.showingSettingsView = true}) {
                                                        Image(systemName: "gear").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                                                    }.padding(.leading, 2.0)

                                                    Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5)
                                                    Button(action: {
                                                      //  withAnimation(.spring())
                                                      //  {
                                                            self.uniformlistshows.toggle()
                                                       // }

                                                    }) {
                                                        Image(systemName: self.uniformlistshows ? "square.righthalf.fill" : "square.lefthalf.fill").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                                                    }
                                                }.padding(.top, -5).frame(height: 40)
//                .toolbar() {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {self.showingSettingsView = true}) {
//                            Image(systemName: "gear").resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12).frame(height: 100)
//                        }.buttonStyle(PlainButtonStyle()).foregroundColor(colorScheme == .light ? Color.black : Color.white).padding(.leading, 2.0)
//                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: {
//                           // withAnimation(.spring())
//                           // {
//                                self.uniformlistshows.toggle()
//                            //}
//
//                        }) {
//                            Image(systemName: self.uniformlistshows ? "square.righthalf.fill" : "square.lefthalf.fill").resizable().scaledToFit().foregroundColor(colorScheme == .light ? Color.black : Color.white).font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12).frame(height: 100)
//                        }.buttonStyle(PlainButtonStyle())
//                    }
//                    ToolbarItem(placement: .principal) {
//                        Image(self.colorScheme == .light ? "Tracr" : "TracrDark").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 3.5).offset(y: 5).frame(height: 100)
//                    }
//                }
                )
            } else {
                // Fallback on earlier versions
            }
                                //Spacer().frame(height: 10)
                                
            //.navigationBarTitle(self.uniformlistshows ? "Tasks" : "")

        }.onDisappear() {
            let defaults = UserDefaults.standard
            self.showingSettingsView = false
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
