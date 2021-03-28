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
class WeeklyBlockViewDateSelector: ObservableObject {
    @Published var dateIndex: Int = 0
  //  @Published var alertView: AlertView = .none
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
    @ObservedObject var dateselector: WeeklyBlockViewDateSelector = WeeklyBlockViewDateSelector()
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    func getassignmentsbydate(index: Int) -> [String] {
        var ans: [String] = []

        
        for assignment in assignmentlist {

            if (assignment.completed == false)
            {
                let diff = Calendar.current.isDate(Date(timeInterval: 0, since: self.datesfromlastmonday[self.datenumberindices[index]]), equalTo: Date(timeInterval: 0, since: assignment.duedate), toGranularity: .day)
                if (diff == true)
                {
                    ans.append(assignment.color)
                }
                    
            }
        }
        return ans
    }
    
    func getassignmentsbydateindex(index: Int, index2: Int) -> String {
        if (index2 < self.getassignmentsbydate(index: index).count)
        {
            return self.getassignmentsbydate(index: index)[index2]
        }
    
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
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }

    
    var body: some View {
        ZStack {
            HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                ForEach(self.datenumberindices.indices) { index in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("datenumberred")).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3).opacity(self.datenumberindices[index] == self.nthdayfromnow ? 1 : 0)
                            
                            let calendar = Calendar.current
                            
//                            calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
                            
                            Text(self.datenumbersfromlastmonday[self.datenumberindices[index]]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(self.datenumberindices[index] == Calendar.current.dateComponents([.day], from: calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! ? .bold : .regular)
                        }.contextMenu {
                            Button(action: {
                                    self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
                                dateselector.dateIndex = self.datenumberindices[index]
                            }) {
                                Text("Add Assignment")
                                Image(systemName: "paperclip")
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
                            ForEach(self.getassignmentsbydate(index: index).indices, id: \.self) { index2 in
                                if (self.getassignmentsbydateindex(index: index, index2: index2) == "zero")
                                {
                                    
                                }
                                else
                                {
                                    Circle().fill(self.getassignmentsbydateindex(index: index, index2: index2).contains("rgbcode") ? GetColorFromRGBCode(rgbcode: self.getassignmentsbydateindex(index: index, index2: index2)) : Color(self.getassignmentsbydateindex(index: index, index2: index2))).frame(width: 5, height:  5).offset(x: self.getoffsetfromindex(assignmentsindex: index2, index: index))
                                }
                            }
                        }
                        Spacer()
                    }
                }
                
            }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0, preselecteddate: dateselector.dateIndex).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).alert(isPresented: $noClassesAlert) {
                Alert(title:  Text("No Classes Added"), message: Text("Add a Class First"))
            }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29))

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
    
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.name, ascending: true)])
    var addtimeloglist: FetchedResults<AddTimeLog>
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @EnvironmentObject var actionViewPresets: ActionViewPresets

    @EnvironmentObject var masterRunning: MasterRunning
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }

    var body : some View {
        HStack {
            Text("Add Time to Assignment").font(.system(size: 14)).fontWeight(.light)
            Spacer()
            Button(action: {
                actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                actionViewPresets.actionViewHeight = 1
                actionViewPresets.actionViewType = ""
            }, label: {
                Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.black)
            })
        }.frame(width: UIScreen.main.bounds.size.width - 75)
        
        Spacer()
        
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(addTimeSubassignment.subassignmentcolor.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: addTimeSubassignment.subassignmentcolor) : Color(addTimeSubassignment.subassignmentcolor)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
                )
                
                Spacer().frame(width: 15)
                
                VStack {
                    HStack {
                        Text(addTimeSubassignment.subassignmentname).font(.system(size: 17)).fontWeight(.medium)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 6)
                    
                    HStack {
                        Text(addTimeSubassignment.subassignmentstarttimetext + " - " + addTimeSubassignment.subassignmentendtimetext).font(.system(size: 15)).fontWeight(.light)
                        
                        Spacer()
                        
                        Text(addTimeSubassignment.subassignmentdatetext).font(.system(size: 15)).fontWeight(.light)
                        
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
                Slider(value: $addTimeSubassignment.subassignmentcompletionpercentage, in: 0...100)
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Text("\(addTimeSubassignment.subassignmentcompletionpercentage.rounded(.down), specifier: "%.0f")%")
            Text("≈ \(Int((addTimeSubassignment.subassignmentcompletionpercentage / 100) * Double(addTimeSubassignment.subassignmentlength) / 5) * 5) minutes").fontWeight(.light)
        }
        
        Spacer()
        
        Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 0.4)
        if masterRunning.masterRunningNow {
            MasterClass()
        }
        Button(action: {
            let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

            newAddTimeLog.name = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentname
            newAddTimeLog.length = Int64(addTimeSubassignment.subassignmentlength)
            newAddTimeLog.color = self.subassignmentlist[addTimeSubassignment.subassignmentindex].color
            newAddTimeLog.starttime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].startdatetime
            newAddTimeLog.endtime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].enddatetime
            newAddTimeLog.date = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentduedate
            newAddTimeLog.completionpercentage = addTimeSubassignment.subassignmentcompletionpercentage
            
            actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
            actionViewPresets.actionViewHeight = 1
            
            self.managedObjectContext.delete(self.subassignmentlist[addTimeSubassignment.subassignmentindex])
            
            for (_, element) in self.assignmentlist.enumerated() {
                if (element.name == addTimeSubassignment.subassignmentname) {
                    let minutescompleted = (addTimeSubassignment.subassignmentcompletionpercentage / 100) * Double(addTimeSubassignment.subassignmentlength)
                    let minutescompletedroundeddown = Int(minutescompleted / 5) * 5
                    element.timeleft -= Int64(minutescompletedroundeddown)
                    element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                }
            }
                
            masterRunning.masterRunningNow = true
            masterRunning.displayText = true
            print("Signal Sent.")
            
            do {
                try self.managedObjectContext.save()
                print("AddTime logged")
            } catch {
                print(error.localizedDescription)
            }
        }) {
            Text("Done").font(.system(size: 17)).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
        }.padding(.vertical, 8).padding(.bottom, -3)
    }
}

struct SubassignmentBacklogAction: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @State var subPageType: String = "Introduction"
    @State var subassignmentcompletionpercentage: Double = 0
    @State var nthTask: Int = 1
    
    @EnvironmentObject var masterRunning: MasterRunning

    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    
    var body: some View {
        if self.subPageType == "Introduction" {
            HStack {
                Text(addTimeSubassignmentBacklog.backlogList.count > 1 ? "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Tasks" : "Tasks Backlog - \(addTimeSubassignmentBacklog.backlogList.count) Task").font(.system(size: 14)).fontWeight(.light)
                Spacer()
                Button(action: {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                    
                    let defaults = UserDefaults.standard
                    defaults.set(Date(), forKey: "lastNudgeDate")
                }, label: {
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.black)
                })
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer()
            
            VStack {
                HStack {
                    Text("You have the following tasks in your backlog:").font(.system(size: 16)).fontWeight(.light)
                    
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 75)
                
                Spacer().frame(height: 15)
                
                ScrollView() {
                    ForEach(0..<addTimeSubassignmentBacklog.backlogList.count) { subassignmentindex in
                        HStack {
                            let subassignmentcolortemp = addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentcolor"] ?? "datenumberred"
                            RoundedRectangle(cornerRadius: 3, style: .continuous).fill(subassignmentcolortemp.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignmentcolortemp) : Color(subassignmentcolortemp)).frame(width: 12, height: 12).overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black, lineWidth: 0.6)
                            )
                            
                            Spacer().frame(width: 15)
                            
                            Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentname"] ?? "FAIL").font(.system(size: 17)).fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentdatetext"] ?? "FAIL").font(.system(size: 15)).fontWeight(.light)
                        }.padding(.horizontal, 10).frame(width: UIScreen.main.bounds.size.width - 75, height: 25)
                    }
                }.frame(height: CGFloat(min((addTimeSubassignmentBacklog.backlogList.count * 32), 90)))
                
                HStack {
                    Text("Would you like to update your progress on these tasks?").font(.system(size: 16)).fontWeight(.light)
                    
                    Spacer()
                }.frame(width: UIScreen.main.bounds.size.width - 75)
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 0.4)
            
            HStack {
                Button(action: {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                    
                    let defaults = UserDefaults.standard
                    defaults.set(Date(), forKey: "lastNudgeDate")
                }) {
                    Text("Nudge Me Later").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.red).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                }
                
                Spacer()
                
                Rectangle().fill(Color.gray).frame(width: 0.4, height: 25)
                
                Spacer()
                
                Button(action: {
                    self.subPageType = "Tasks"
                    actionViewPresets.actionViewHeight = 280
                }) {
                    Text("Continue").font(.system(size: 17)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                }
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
        
        else if self.subPageType == "Tasks" {
            HStack {
                Text("Tasks Backlog (\(self.nthTask)/\(addTimeSubassignmentBacklog.backlogList.count + self.nthTask - 1))").font(.system(size: 14)).fontWeight(.light)
                Spacer()
                Button(action: {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    actionViewPresets.actionViewType = ""
                    
                    self.subPageType = ""
                    let defaults = UserDefaults.standard
                    defaults.set(Date(), forKey: "lastNudgeDate")
                }, label: {
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundColor(.black)
                })
            }.frame(width: UIScreen.main.bounds.size.width - 75)
            
            Spacer()
            
            VStack {
                HStack {
                    let subassignmentcolortemp2 = addTimeSubassignmentBacklog.backlogList[0]["subassignmentcolor"] ?? "one"
                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(subassignmentcolortemp2.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: subassignmentcolortemp2) : Color(subassignmentcolortemp2)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
                    )

                    Spacer().frame(width: 15)
                    
                    VStack {
                        HStack {
                            Text(addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL").font(.system(size: 17)).fontWeight(.medium)

                            Spacer()
                        }

                        Spacer().frame(height: 6)

                        HStack {
                            Text((addTimeSubassignmentBacklog.backlogList[0]["subassignmentstarttimetext"] ?? "FAIL") + " - " + (addTimeSubassignmentBacklog.backlogList[0]["subassignmentendtimetext"] ?? "FAIL")).font(.system(size: 15)).fontWeight(.light)

                            Spacer()

                            Text(addTimeSubassignmentBacklog.backlogList[0]["subassignmentdatetext"] ?? "FAIL").font(.system(size: 15)).fontWeight(.light)

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
                    Slider(value: self.$subassignmentcompletionpercentage, in: 0...100)
                }.frame(width: UIScreen.main.bounds.size.width - 75)

                Text("\(self.subassignmentcompletionpercentage.rounded(.down), specifier: "%.0f")%")
                Text("≈ \(Int((self.subassignmentcompletionpercentage / 100) * (Double(addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0") ?? 0) / 5) * 5) minutes").fontWeight(.light)
            }
            
            Spacer()
            
            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-75, height: 0.4)
            
            Button(action: {
                let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

                newAddTimeLog.name = addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL"
                newAddTimeLog.length = Int64(addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0") ?? 0
                newAddTimeLog.color = addTimeSubassignmentBacklog.backlogList[0]["subassignmentcolor"] ?? "one"
                newAddTimeLog.starttime = self.subassignmentlist[0].startdatetime
                newAddTimeLog.endtime = self.subassignmentlist[0].enddatetime
                newAddTimeLog.date = self.subassignmentlist[0].assignmentduedate
                newAddTimeLog.completionpercentage = self.subassignmentcompletionpercentage
                
                self.nthTask += 1

                if addTimeSubassignmentBacklog.backlogList.count == 1 {
                    actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                    actionViewPresets.actionViewHeight = 1
                    self.subPageType = ""
                    self.nthTask = 1
                    masterRunning.displayText = true
                }

                self.managedObjectContext.delete(self.subassignmentlist[0])
                
                for (_, element) in self.assignmentlist.enumerated() {
                    if (element.name == addTimeSubassignmentBacklog.backlogList[0]["subassignmentname"] ?? "FAIL") {
                        let lengthAsDouble = Double((addTimeSubassignmentBacklog.backlogList[0]["subassignmentlength"] ?? "0.0").replacingOccurrences(of: "[^\\.\\d+]", with: "", options: [.regularExpression])) ?? 0.0
                        let minutescompleted = (self.subassignmentcompletionpercentage / 100) * lengthAsDouble
                        print(lengthAsDouble, minutescompleted)
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
                
                self.subassignmentcompletionpercentage = 0
                
                addTimeSubassignmentBacklog.backlogList.remove(at: 0)
                
                masterRunning.masterRunningNow = true
                print("Signal Sent.")
            }) {
                Text(addTimeSubassignmentBacklog.backlogList.count > 1 ? "Next" : "Done").font(.system(size: 17)).fontWeight(.semibold).frame(width: UIScreen.main.bounds.size.width-80, height: 25)
            }.padding(.vertical, 8).padding(.bottom, -3)
        }
        
        if masterRunning.masterRunningNow {
            MasterClass()
        }
    }
}

struct NoClassesOrFreetime: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var actionViewPresets: ActionViewPresets

//    @EnvironmentObject var masterRunning: MasterRunning
//
//    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
//        if number == 1 {
//            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
//        }
//
//        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
//    }
    @State var NewSheetPresenting = false
    
    @Binding var noclasses: Bool
    @Binding var nofreetime: Bool
    @Binding var subpage: String
    
    var body : some View {
        VStack {
            HStack {
                Text("Quick Setup – Reminder").font(.system(size: subpage == "None" ? 29 : 20)).fontWeight(.light)
                Spacer()
            }.padding(.all, 5).padding(.horizontal, subpage == "None" ? 0 : 19)
            
            if subpage == "None" {
                VStack(spacing: 5) {
                    HStack {
                        Text("In order to plan your schedule, you need to first add your free times and add at least one class.").font(.system(size: 14)).fontWeight(.light)
                        Spacer()
                    }.padding(.horizontal, 5)
                    HStack {
                        Text("You can do this by holding the blue Add button and selecting 'Free Time' and 'Class'").font(.system(size: 14)).fontWeight(.semibold)
                        Spacer()
                    }.padding(.horizontal, 5)
                }
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "clock").resizable().scaledToFit().frame(width: subpage == "None" ? 23 : 15)
                Spacer().frame(width: subpage == "None" ? 30 : 15)
                Text("Free Time").font(.system(size: subpage == "None" ? 21 : 15)).fontWeight(.light)
                Spacer()
                if nofreetime {
                    Image(systemName: "xmark").foregroundColor(.red)
                }
                else {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
            }.padding(.all, subpage == "None" ? 10 : 5).padding(.horizontal, subpage == "None" ? 10 : 30)
            
            HStack {
                Image(systemName: "list.bullet").resizable().scaledToFit().frame(width: subpage == "None" ? 23 : 15)
                Spacer().frame(width: subpage == "None" ? 30 : 15)
                Text("Classes").font(.system(size: subpage == "None" ? 21 : 15)).fontWeight(.light)
                Spacer()
                if noclasses {
                    Image(systemName: "xmark").foregroundColor(.red)
                }
                else {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
            }.padding(.all, subpage == "None" ? 10 : 5).padding(.horizontal, subpage == "None" ? 10 : 30)
            
            Spacer()
            
            if subpage == "None" {
                HStack {
                    NavigationLink(destination:
                                    TutorialView().navigationBarTitle("Tutorial", displayMode: .inline)//.edgesIgnoringSafeArea(.all)//.padding(.top, -40)
                    ) {
                        HStack {
                            Text("Head to Tutorial").font(.system(size: 17)).fontWeight(.semibold).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                        }.frame(height: 40)
                    }
                    
                    Spacer()
                    
                    Rectangle().fill(Color.gray).frame(width: 0.4, height: 25)
                    
                    Spacer()
                    
                    Button(action: {
                        actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
                        actionViewPresets.actionViewHeight = 1
                        actionViewPresets.actionViewType = ""
                        
                        let defaults = UserDefaults.standard
                        defaults.set(Date(), forKey: "lastNudgeDate")
                    }) {
                        Text("Okay, Got it!").font(.system(size: 17)).fontWeight(.semibold).foregroundColor(Color.green).frame(width: (UIScreen.main.bounds.size.width - 80) / 2, height: 25)
                    }
                }.padding(.vertical, 8).padding(.bottom, -3)
            }
            
//            if subpage == "Class" {
//                NewClassModalView(NewClassPresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext)
//            }
        }.frame(width: subpage == "None" ? UIScreen.main.bounds.size.width-60 : UIScreen.main.bounds.size.width)
    }
}

struct ActionView: View {
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog
    
    @Environment(\.managedObjectContext) var managedObjectContext
 
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    var classlist: FetchedResults<Classcool>
    
    @State var nofreetime: Bool = false
    @State var noclasses: Bool = false
    
    @State var subpageSetup: String = "None"
    
    func initialize() {
        addTimeSubassignmentBacklog.backlogList = []

        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"

        let shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        
        var longDueSubassignment = false
        
        for (_, subassignment) in subassignmentlist.enumerated() {
            if subassignment.enddatetime < Date() {
                var tempAddTimeSubassignment: [String: String] = ["throwawaykey": "throwawayvalue"]

                tempAddTimeSubassignment["subassignmentname"] = subassignment.assignmentname
                tempAddTimeSubassignment["subassignmentlength"] = String(Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!)
                tempAddTimeSubassignment["subassignmentcolor"] = subassignment.color
                tempAddTimeSubassignment["subassignmentstarttimetext"] = timeformatter.string(from: subassignment.startdatetime)
                tempAddTimeSubassignment["subassignmentendtimetext"] = timeformatter.string(from: subassignment.enddatetime)
                tempAddTimeSubassignment["subassignmentdatetext"] = shortdateformatter.string(from: subassignment.startdatetime)

                addTimeSubassignmentBacklog.backlogList.append(tempAddTimeSubassignment)
                
                let calendar = Calendar.current
                
                if calendar.date(byAdding: .day, value: 1, to: subassignment.enddatetime)! < Date() {
                    longDueSubassignment = true
                }
            }
        }

        let defaults = UserDefaults.standard
        let lastNudgeDate = defaults.object(forKey: "lastNudgeDate") as? Date ?? Date()
        
        if ((addTimeSubassignmentBacklog.backlogList.count >= 3) || longDueSubassignment) && (Date(timeInterval: 3600, since: lastNudgeDate) < Date()) && (actionViewPresets.actionViewHeight == 0) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                actionViewPresets.actionViewOffset = 0
                actionViewPresets.actionViewType = "SubassignmentBacklogAction"
                actionViewPresets.actionViewHeight = CGFloat(200 + min((addTimeSubassignmentBacklog.backlogList.count * 32), 90))
            }
        }
        
        //Dealing with No Classes/Freetime
        if freetimelist.isEmpty {
            nofreetime = true
        }
        
        else {
            nofreetime = false
        }
        
        if classlist.isEmpty {
            noclasses = true
        }
        
        else {
            noclasses = false
        }
        
        if (nofreetime || noclasses) && subpageSetup == "None" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(0)) {
                actionViewPresets.actionViewOffset = 0
                actionViewPresets.actionViewType = "NoClassesOrFreetime"
                actionViewPresets.actionViewHeight = CGFloat(330)
            }
        }
    }
    
    var body: some View {
        VStack {
            if actionViewPresets.actionViewType == "SubassignmentAddTimeAction" {
                SubassignmentAddTimeAction()
            }
            
            else if actionViewPresets.actionViewType == "SubassignmentBacklogAction" {
                SubassignmentBacklogAction()
            }
            
            else if actionViewPresets.actionViewType == "NoClassesOrFreetime" {
                NoClassesOrFreetime(noclasses: $noclasses, nofreetime: $nofreetime, subpage: $subpageSetup)
            }
        }.onAppear(perform: initialize).padding(.all, 15).frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: actionViewPresets.actionViewHeight).background(Color("very_light_gray")).cornerRadius(18).padding(.all, 15)
    }
}

struct TimeIndicator: View {
    @Binding var dateForTimeIndicator: Date
    
    var body: some View {
        VStack {
            Spacer().frame(height: 19)
            HStack(spacing: 0) {
                Circle().fill(Color("datenumberred")).frame(width: 12, height: 12)
                Rectangle().fill(Color("datenumberred")).frame(width: UIScreen.main.bounds.size.width-36, height: 2)
                
            }.padding(.top, (CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: dateForTimeIndicator), to: dateForTimeIndicator).second!).truncatingRemainder(dividingBy: 86400))/3600 * 60.35)
            Spacer()
        }
    }
}

struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @Environment(\.colorScheme) var colorScheme: ColorScheme

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
    
    @State var nthdayfromnow: Int = Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day!
    
    @State var nthweekfromnow: Int = 0
    
    @State var selecteddaytitle: Int = 0
    
    var hourformatter: DateFormatter
    var minuteformatter: DateFormatter
    var shortdateformatter: DateFormatter
    @State var subassignmentassignmentname: String = ""
    
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
    
    @State var dateForTimeIndicator = Date()
    @State var scrolling = false
    @State var hidingupcoming = false
    @State var upcomingoffset = 0
    
    @EnvironmentObject var masterRunning: MasterRunning
    let assignmenttypes = ["Homework", "Study", "Test", "Essay", "Presentation/Oral", "Exam", "Report/Paper"]

    init(uniformlistshows: Binding<Bool>, NewAssignmentPresenting2: Binding<Bool>) {
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

        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short

        self.selectedColor  = "one"
        
        let calendar = Calendar.current
        
        let lastmondaydate = calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!)
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: calendar.date(byAdding: .day, value: eachdayfromlastmonday, to: lastmondaydate)!))
        }

    }
    
    func upcomingDisplayTime() -> String {

        
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

        var minuteval: Int = 0
        for (index, _) in subassignmentlist.enumerated() {
            
            minuteval = Calendar.current
                .dateComponents([.minute], from: Date(timeIntervalSinceNow: TimeInterval(0)), to: subassignmentlist[index].startdatetime)
            .minute!
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
    
    func getNextColor(currentColor: String) -> Color {
        let colorlist = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "one"]
        let existinggradients = ["one", "two", "three", "five", "six", "eleven","thirteen", "fourteen", "fifteen"]
        if (existinggradients.contains(currentColor)) {
            return Color(currentColor + "-b")
        }
        for color in colorlist {
            if (color == currentColor) {
                return Color(colorlist[colorlist.firstIndex(of: color)! + 1])
            }
        }
        return Color("one")
    }
    
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
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
                                Text(daytitlesfromlastmonday[index]).font(.title).fontWeight(.medium).tag(index)//.frame(height: 40)
                            }
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 40).disabled(true)//.animation(.spring())
                        
                    } else {
                        DummyPageViewControllerForDates(increased: self.$increased, stopupdating: self.$stopupdating, viewControllers: [UIHostingController(rootView: Text(daytitlesfromlastmonday[self.nthdayfromnow]).font(.title).fontWeight(.medium))]).frame(width: UIScreen.main.bounds.size.width-40, height: 40)
                    }
            

                        ZStack {
                        ZStack {
                            if (subassignmentlist.count > 0) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: selectedColor.contains("rgbcode") ? [GetColorFromRGBCode(rgbcode: selectedColor, number: 1), GetColorFromRGBCode(rgbcode: selectedColor, number: 2)] : [getNextColor(currentColor: selectedColor), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
                            }
                            
                            
                            else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("three"), Color("three-b")]), startPoint: .leading, endPoint: .trailing))
                            }

                            HStack {
                                VStack(alignment: .leading) {
                                    if (subassignmentlist.count == 0) {
                                        Text("No Upcoming Tasks").font(.system(size: 19))
                                    }
                                    else if (self.getsubassignment() == -1 || self.upcomingDisplayTime() == "No Upcoming Subassignments") {
                                        Text("No Upcoming Tasks").font(.system(size: 19))
                                    }
                                    else {
                                        Text("Coming Up:").fontWeight(.semibold)//.animation(.none)
                                        Text(self.upcomingDisplayTime()).frame(width: self.subassignmentassignmentname == "" ? 200: 150, height:30, alignment: .topLeading)//.animation(.none)

                                        Text(subassignmentlist[self.getsubassignment()].assignmentname).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(height:20)
                                        Text(timeformatter.string(from: subassignmentlist[self.getsubassignment()].startdatetime) + " - " + timeformatter.string(from: subassignmentlist[self.getsubassignment()].enddatetime)).font(.system(size: 15)).frame(height:20)
                                    }
                                }.frame(width:self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60:150)//.animation(.none)

                                if self.subassignmentassignmentname != "" {
                                    Spacer().frame(width: 10)
                                    Divider().frame(width: 1).background(Color.black)
                                    Spacer().frame(width: 10)
                                    VStack(alignment: .leading) {
                                        ForEach(self.assignmentlist) { assignment in
                                            if (assignment.name == self.subassignmentassignmentname) {
                                                Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 25, alignment: .topLeading)
                                                Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 12)).frame(height:15)
                                                Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                                UpcomingSubassignmentProgressBar(assignment: assignment).frame(height:10)
                                            }
                                        }
                                    }.frame(width: 150)
                                }
                            }.padding(10)
                            

                        }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10).animation(.spring()).offset(y:-CGFloat(upcomingoffset))
                            HStack {

                                Spacer()
                                Button(action:{
                                    self.hidingupcoming.toggle()
                                    print(hidingupcoming)
                                    if (self.hidingupcoming)
                                    {
                                        upcomingoffset = Int(UIScreen.main.bounds.size.height)
                                    }
                                    else
                                    {
                                        upcomingoffset = 0
                                    }
                                    print(upcomingoffset)
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: self.hidingupcoming ? 2.5 : 0, style: .continuous).fill(Color.blue).frame(width: 15, height: self.hidingupcoming ? 15 : 60)
                                        Image(systemName: "chevron.compact.right").resizable().frame(width: 4, height: self.hidingupcoming ? 8 : 30).foregroundColor(colorScheme == .light ? Color.white : Color.black)
                                    }
                                }.rotationEffect(Angle(degrees: self.hidingupcoming ? 90 : 0), anchor: .top).animation(.spring())
                            }.padding(.top, self.hidingupcoming ? -50 : 0)
                        }.frame(width: UIScreen.main.bounds.size.width).animation(.spring())
                                                    
                VStack {
                    ScrollView {
                        ZStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    ForEach((0...24), id: \.self) { hour in
                                        HStack {
                                            Text(String(format: "%02d", hour)).font(.system(size: 13)).frame(width: 20, height: 20)
                                            Rectangle().fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-50, height: 0.5)
                                        }
                                        if masterRunning.masterRunningNow {
                                            MasterClass()
                                        }
                                    }.frame(height: 50).animation(.spring())
                                }
                            }

                            HStack(alignment: .top) {
                                Spacer()
                                VStack {
                                    Spacer().frame(height: 25)
                                    
                                    ZStack(alignment: .topTrailing) {
                                        ForEach(subassignmentlist) { subassignment in

                                            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.shortdateformatter.string(from: self.datesfromlastmonday[self.nthdayfromnow])) {
                                                IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: false, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment, isrepeated: false).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: subassignment.startdatetime), to: subassignment.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3).onTapGesture {
                                                    self.subassignmentassignmentname = subassignment.assignmentname
                                                    self.selectedColor = subassignment.color

                                                }
                                                    //was +122 but had to subtract 2*60.35 to account for GMT + 
                                            }
                                        }.animation(.spring())
                                    }
                                    Spacer()
                                }
                            }

                            if (Calendar.current.isDate(self.datesfromlastmonday[self.nthdayfromnow], equalTo: Date(timeIntervalSinceNow: TimeInterval(0)), toGranularity: .day)) {
                                TimeIndicator(dateForTimeIndicator: self.$dateForTimeIndicator).onReceive(timer) { input in
                                    self.dateForTimeIndicator = input
                                }
                            }
                        }
                    }
                }.padding(.top, self.hidingupcoming ? -100 : 0).animation(.spring())
            }//.transition(.move(edge: .leading)).animation(.spring())
        }
        else {
            VStack {
                HStack {
                    Text("Tasks").font(.largeTitle).bold()
                    Spacer()
                }.padding(.all, 10).padding(.leading, 10)
                
                ZStack {
                ZStack {
                    if (subassignmentlist.count > 0) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: selectedColor.contains("rgbcode") ? [GetColorFromRGBCode(rgbcode: selectedColor, number: 1), GetColorFromRGBCode(rgbcode: selectedColor, number: 2)] : [getNextColor(currentColor: selectedColor), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
                    }

                    else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [Color("three"), Color("three-b")]), startPoint: .leading, endPoint: .trailing))
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                ForEach(self.assignmentlist) { assignment in
                                    if (assignment.name == self.subassignmentassignmentname) {
                                        Text(assignment.name).font(.system(size: 20)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 80)//.offset(y: 5)
                                    }
                                }
                                if (self.subassignmentassignmentname == "") {
                                    Text("No Task Selected").font(.system(size: 22)).multilineTextAlignment(.leading).lineLimit(nil).frame(width: UIScreen.main.bounds.size.width-60, height: 80, alignment: .center)
                                }
                            }
                        }.frame(width:self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60:150)//.animation(.none)

                        if self.subassignmentassignmentname != "" {
                            Spacer().frame(width: 10)
                            Divider().frame(width: 1).background(Color.black)
                            Spacer().frame(width: 20)
                            VStack(alignment: .leading) {
                                ForEach(self.assignmentlist) { assignment in
                                    if (assignment.name == self.subassignmentassignmentname) {


                                        Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 15)).fontWeight(.bold).frame(height:40)
                                        Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                        Text("Work Left: \(assignment.timeleft / 60)h \(assignment.timeleft % 60)m").font(.system(size: 12)).frame(height: 15)
                                        UpcomingSubassignmentProgressBar(assignment: assignment).frame(height: 10)
                                        Spacer().frame(height: 10)
                                    }
                                }
                            }.frame(width: 150)
                        }
                        
                    }//.padding(10)
                }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10).animation(.spring()).offset(y:-CGFloat(upcomingoffset))
                    HStack {
                        
                        Spacer()
                        Button(action:{
                            self.hidingupcoming.toggle()
                            print(hidingupcoming)
                            if (self.hidingupcoming)
                            {
                                upcomingoffset = Int(UIScreen.main.bounds.size.height)
                            }
                            else
                            {
                                upcomingoffset = 0
                            }
                            print(upcomingoffset)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: self.hidingupcoming ? 2.5 : 0, style: .continuous).fill(Color.blue).frame(width: 15, height: self.hidingupcoming ? 15 : 60)
                                Image(systemName: "chevron.compact.right").resizable().frame(width: 4, height: self.hidingupcoming ? 8 : 30).foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            }
                        }.rotationEffect(Angle(degrees: self.hidingupcoming ? 90 : 0), anchor: .top).animation(.spring())
                    }.padding(.top, self.hidingupcoming ? -50 : 0)
                }.frame(width: UIScreen.main.bounds.size.width).animation(.spring())
                ScrollView {

                    let calendar = Calendar.current

                ForEach(0 ..< daytitlesfromlastmonday.count) { daytitle in
                    if (Calendar.current.dateComponents([.day], from: calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? calendar.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : calendar.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! <= daytitle)
                    {
                        SubassignmentListView(daytitle: self.daytitlesfromlastmonday[daytitle],  daytitlesfromlastmonday: self.daytitlesfromlastmonday, datesfromlastmonday: self.datesfromlastmonday, subassignmentassignmentname: self.$subassignmentassignmentname, selectedcolor: self.$selectedColor, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment).animation(.spring())
                    }
                }.animation(.spring())
                    
                if subassignmentlist.count == 0 {
                    Spacer().frame(height: 100)
                    Image(colorScheme == .light ? "emptyassignment" : "emptyassignmentdark").resizable().aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.size.width-100)//.frame(width: UIScreen.main.bounds.size.width, alignment: .center)//.offset(x: -20)
                    Text("No Tasks!").font(.system(size: 40)).frame(width: UIScreen.main.bounds.size.width - 40, height: 100, alignment: .center).multilineTextAlignment(.center)
                }

                }.padding(.top, self.hidingupcoming ? -100 : 0).animation(.spring())
            }//.transition(.move(edge: .leading)).animation(.spring())
        }
        }.sheet(isPresented: $showeditassignment, content: {
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject, assignmenttype: self.assignmenttypes.firstIndex(of: self.assignmentlist[self.getassignmentindex()].type)!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)})
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
    
    @Binding var subassignmentassignmentname: String
    @Binding var selectedcolor: String
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    var shortdateformatter: DateFormatter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(daytitle: String, daytitlesfromlastmonday: [String], datesfromlastmonday: [Date], subassignmentassignmentname: Binding<String>, selectedcolor: Binding<String>, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>)
    {
        self.daytitle = daytitle

        self._subassignmentassignmentname = subassignmentassignmentname
        self._selectedcolor = selectedcolor
        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
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
    func isrepeatedsubassignment(assignmentname: String) -> Bool {
        var counter = 0
        for subassignment in subassignmentlist {
            if (subassignment.assignmentname == assignmentname && self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring())
            {
                counter += 1
            }
        }
        if (counter >= 2)
        {
            return true
        }
        return false
    }
    func isfirstofgroup(subassignment3: Subassignmentnew) -> Bool {
        for subassignment in subassignmentlist {
            if (subassignment3.assignmentname == subassignment.assignmentname &&  self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring() )
            {
                if (subassignment.startdatetime == subassignment3.startdatetime)
                {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    @State var tasksThereBool: Bool = false
    
    func tasksThereFunc() {
        tasksThereBool = true
    }
    
    var body: some View {
      //  ScrollView {
        
        if tasksThereBool {
            HStack {
                Spacer().frame(width: 10)
                Text(daytitle).font(.system(size: 20)).foregroundColor(daytitlesfromlastmonday.firstIndex(of: daytitle) == Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)! > Date() ? Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfWeek!)! : Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfWeek!)!, to: Date()).day! ? Color.blue : Color("blackwhite")).fontWeight(.bold)
                Spacer()
            }.frame(width: UIScreen.main.bounds.size.width, height: 40).background(Color("add_overlay_bg"))
        }
        
//        else {
//            Rectangle().fill(Color.black).frame(height: 1).padding(.all, 0).position(x: 0, y: 0)
//        }
        
        ForEach(subassignmentlist) {
            subassignment in
            if (self.shortdateformatter.string(from: subassignment.startdatetime) == self.getcurrentdatestring()) {
                if (isrepeatedsubassignment(assignmentname: subassignment.assignmentname))
                {
                    if (isfirstofgroup(subassignment3: subassignment))
                    {
                        IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment, isrepeated: true).onTapGesture {
                            selectedcolor = subassignment.color
                            subassignmentassignmentname = subassignment.assignmentname
                        }.onAppear(perform: tasksThereFunc)
                    }
                }
                else
                {
                    IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment, isrepeated: false).onTapGesture {
                        selectedcolor = subassignment.color
                        subassignmentassignmentname = subassignment.assignmentname
                    }.onAppear(perform: tasksThereFunc)
                }//was +122 but had to subtract 2*60.35 to account for GMT + 2
            }
            
        }.animation(.spring())
        
        if masterRunning.masterRunningNow {
            MasterClass()
        }
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
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @FetchRequest(entity: AssignmentTypes.entity(), sortDescriptors: [])

    var assignmenttypeslist: FetchedResults<AssignmentTypes>
    
    var starttime, endtime, color, name, duedate: String
    var actualstartdatetime, actualenddatetime, actualduedate: Date
    @State var isDragged: Bool = false
    @State var isDraggedleft: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var incompleted: Bool = false
    @State var incompletedonce: Bool = true
    @State var dragoffset = CGSize.zero
    
    @State var isrepeated: Bool
    var fixedHeight: Bool
    
    var subassignmentlength: Int
 
    var subassignment: Subassignmentnew
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @Binding var showeditassignment: Bool
    @Binding var selectededitassignment: String
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    let screenval = -UIScreen.main.bounds.size.width
    
    var shortdateformatter: DateFormatter
    
    init(subassignment2: Subassignmentnew, fixedHeight: Bool, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>, isrepeated: Bool) {

        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        self.endtime = formatter.string(from: subassignment2.enddatetime)

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
        self._isrepeated = State(initialValue: isrepeated)
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
    }
    
    func getgrouplength() -> Int {
        var totallength = 0
        for subassignment2 in subassignmentlist {
            if (Calendar.current.startOfDay(for: subassignment2.startdatetime) == Calendar.current.startOfDay(for: self.actualstartdatetime) && self.name == subassignment2.assignmentname)
            {
                totallength += Calendar.current.dateComponents([.minute], from: subassignment2.startdatetime, to: subassignment2.enddatetime).minute!
            }
        }
        return totallength
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("phone vibrated")
    }
 
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }

    
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                        HStack {
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +    CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).offset(x: self.fixedHeight ? UIScreen.main.bounds.size.width - 10 + self.dragoffset.width : UIScreen.main.bounds.size.width-30+self.dragoffset.width)
                        }
                        HStack {
                            Spacer()

                                Text("Complete").foregroundColor(Color.white).frame(width:self.dragoffset.width < -110 ? self.fixedHeight ? 100 : 120 : 120).offset(x: self.dragoffset.width < -110 ? 0: self.fixedHeight ? self.dragoffset.width + 120 : self.dragoffset.width + 110)
                        }
                    }
                }
                if (isDraggedleft) {
                    ZStack {
                        HStack {
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +  CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).offset(x: self.fixedHeight ? screenval+10+self.dragoffset.width : -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
                        }
                        
                        HStack {

                            Text("Add Time").foregroundColor(Color.white).frame(width:120).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -120 : -150 : self.fixedHeight ? self.dragoffset.width - 270 : self.dragoffset.width-300)
                            Image(systemName: "timer").foregroundColor(Color.white).frame(width:50).offset(x: self.dragoffset.width > 150 ? self.fixedHeight ? -160 : -190 : self.fixedHeight ? self.dragoffset.width - 310 : self.dragoffset.width-340)
                        }
                    }
                }
            }
            
            VStack {
                if (fixedHeight)
                {
                    Text(self.name).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    Spacer().frame(height: 10)
                    if (self.isrepeated)
                    {
                        Text((self.getgrouplength()/60 == 0 ? "" : (self.getgrouplength()/60 == 1 ? "1 hour" : String(self.getgrouplength()/60) + " hours "))  + (self.getgrouplength() % 60 == 0 ? "" : String(self.getgrouplength() % 60) + " minutes")).frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                    else
                    {
                        Text((self.subassignmentlength/60 == 0 ? "" : (self.subassignmentlength/60 == 1 ? "1 hour" : String(self.subassignmentlength/60) + " hours ")) + (self.subassignmentlength % 60 == 0 ? "" : String(self.subassignmentlength % 60) + " minutes")).frame(width:  self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                }
                else
                {
                    if (subassignmentlength < 30)
                    {
                        HStack{
                            Text(self.name).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading).padding(.top, 5)

                            
                            Text(self.starttime + " - " + self.endtime).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                            
                        }
                    }
                    else
                    {
                        Text(self.name).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading).padding(.top, 5)

                        
                        Text(self.starttime + " - " + self.endtime).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                    }
                }

                Spacer()

            }.frame(height: fixedHeight ? 50 : 38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).padding(12).background(color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: color) : Color(color)).cornerRadius(10).contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous)).offset(x: self.dragoffset.width).contextMenu {
                Button(action:{
                    self.showeditassignment = true
                    self.selectededitassignment = subassignment.assignmentname
                })
                {
                        Text("Edit Assignment")
                        Image(systemName: "pencil.circle")
                }
            }.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
 
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
                                        
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 1/2) {
                        self.deleted = true
                    }
                    else if (self.dragoffset.width > UIScreen.main.bounds.size.width * 1/2) {
                        self.incompleted = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                        self.dragoffset = .zero
                    }
                }
                .onEnded { value in
                    self.dragoffset = .zero
                    

                    print("drag gesture ended")
                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
                            print("incompleted")
                            
                            actionViewPresets.actionViewOffset = 0
                            actionViewPresets.actionViewHeight = 280
                            actionViewPresets.actionViewType = "SubassignmentAddTimeAction"
                            addTimeSubassignment.subassignmentname = self.name
                            if (isrepeated)
                            {
                                addTimeSubassignment.subassignmentlength = self.getgrouplength()
                            }
                            else
                            {
                                addTimeSubassignment.subassignmentlength = self.subassignmentlength
                            }
                            addTimeSubassignment.subassignmentcolor = self.color
                            addTimeSubassignment.subassignmentstarttimetext = self.starttime
                            addTimeSubassignment.subassignmentendtimetext = self.endtime
                            addTimeSubassignment.subassignmentdatetext = self.shortdateformatter.string(from: self.actualstartdatetime)
                            addTimeSubassignment.subassignmentcompletionpercentage = 0
                            
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                    addTimeSubassignment.subassignmentindex = index
                                }
                            }
                        }
                    }
                    
                    else if (self.deleted == true) {
                        print("success")
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            print("deleting")
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name) {
                                    var minutes = self.subassignmentlength
                                    if (isrepeated)
                                    {
                                        minutes = self.getgrouplength()
                                    }
                                    else
                                    {
                                        minutes = self.subassignmentlength
                                    }
                                    
                                    element.timeleft -= Int64(minutes)
                                    print(element.timeleft)
                                    withAnimation(.spring()) {
                                        if (element.totaltime != 0) {
                                            element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                        }
                                        else {
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
                                if (isrepeated)
                                {
                                    if (Calendar.current.startOfDay(for: element.startdatetime) == Calendar.current.startOfDay(for: self.actualstartdatetime) && element.assignmentname == self.name)
                                    {
                                        self.managedObjectContext.delete(self.subassignmentlist[index])
                                    }
                                }
                                else
                                {
                                    if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name) {
                                        self.managedObjectContext.delete(self.subassignmentlist[index])
                                    }
                                }
                            }
                            do {
                                try self.managedObjectContext.save()
                                print("Subassignment completed")
                            } catch {
                                print(error.localizedDescription)
                            }
                            simpleSuccess()
                            masterRunning.masterRunningNow = true
                            masterRunning.displayText = true
                            print("Signal Sent.")
                        }
                    }
                }).animation(.spring())
        }.frame(width: UIScreen.main.bounds.size.width-40).onDisappear {
            self.dragoffset.width = 0
        }
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
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    
    @State var noClassesAlert = false
    
    @State var noCompletedAlert = false
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
    @State var uniformlistshows: Bool
    @State var showingSettingsView = false
    @State var modalView: ModalView = .none
    @State var alertView: AlertView = .noclass
    @State var NewSheetPresenting = false
    @State var NewAlertPresenting = false
    @ObservedObject var sheetNavigator = SheetNavigator()
    @State var showpopup: Bool = false
    @State var widthAndHeight: CGFloat = 50
    
    init() {
        let defaults = UserDefaults.standard
        let viewtype = defaults.object(forKey: "savedtoggleview") as? Bool ?? false
        _uniformlistshows = State(initialValue: viewtype)
    }
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @ViewBuilder
    private func sheetContent() -> some View {        
        if (self.sheetNavigator.modalView == .freetime) {
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            //NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
            NewGoogleAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
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
           NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)

        }
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ZStack {
                    
                    NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                        { EmptyView() }
                    HomeBodyView(uniformlistshows: self.$uniformlistshows, NewAssignmentPresenting2: $NewAssignmentPresenting).padding(.top, -40)
                    
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {

                                if (showpopup)
                                {
                                    ZStack() {
                                        Button(action:
                                        {
                                            if (classlist.count > 0)
                                            {
                                                self.sheetNavigator.modalView = .assignment
                                                self.NewSheetPresenting = true
                                             //   self.NewAssignmentPresenting = true
                                            }
                                            else
                                            {
                                                self.sheetNavigator.alertView = .noclass
                                                self.NewAlertPresenting = true
                                            }
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "paperclip")
                                                  .resizable().scaledToFit()
                                               //   .aspectRatio(contentMode: .fit)
                                                    //.padding(.bottom, 20).padding(.trailing, 100)
                                                 // .frame(width: widthAndHeight, height: widthAndHeight)
                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -70, y: 10).shadow(radius: 5)
                                        Button(action:
                                        {
                                            self.sheetNavigator.modalView = .classity
                                            self.NewSheetPresenting = true
                                            self.NewClassPresenting = true
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "list.bullet")
                                                  .resizable().scaledToFit()
                                               //   .aspectRatio(contentMode: .fit)
                                                    //.padding(.bottom, 20).padding(.trailing, 100)
                                                 // .frame(width: widthAndHeight, height: widthAndHeight)
                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -130, y: 10).shadow(radius: 5)

                                        Button(action:
                                        {
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
                                            
                                        })
                                        {
                                              ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.blue)
                                                  .frame(width: widthAndHeight, height: widthAndHeight)
                                                Image(systemName: "percent")
                                                  .resizable().scaledToFit()
                                               //   .aspectRatio(contentMode: .fit)
                                                    //.padding(.bottom, 20).padding(.trailing, 100)
                                                 // .frame(width: widthAndHeight, height: widthAndHeight)
                                                    .foregroundColor(.white).frame(width: widthAndHeight-20, height: widthAndHeight-20)
                                              }.frame(width: widthAndHeight, height: widthAndHeight)
                                        }.offset(x: -190, y: 10).shadow(radius: 5)
                                    }.transition(.scale)
                                  }
                                
                                Button(action: {
     
                                    withAnimation(.spring())
                                    {
                                        self.showpopup.toggle()
                                    }

                                    
                                }) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue).frame(width: 70, height: 70).opacity(1).padding(20).overlay(
                                        ZStack {
                                            //Circle().strokeBorder(Color.black, lineWidth: 0.5).frame(width: 50, height: 50)
                                            Image(systemName: "plus").resizable().foregroundColor(Color.white).frame(width: 30, height: 30).rotationEffect(Angle(degrees: showpopup ? 315 : 0))
                                        }
                                    )
                                }.buttonStyle(PlainButtonStyle()).shadow(radius: 5)
                            }.sheet(isPresented: $NewSheetPresenting, content: sheetContent ).alert(isPresented: $NewAlertPresenting) {
                                Alert(title: self.sheetNavigator.alertView == .noassignment ? Text("No Assignments Completed") : Text("No Classes Added"), message: self.sheetNavigator.alertView == .noassignment ? Text("Complete an Assignment First") : Text("Add a Class First"))
                            }
                            
                            
                            
                            
                        }
                    }
               
                    VStack {
                        Spacer()
                         
                        ActionView().offset(y: actionViewPresets.actionViewOffset).animation(.spring())
                    }.frame(width: UIScreen.main.bounds.size.width).background((actionViewPresets.actionViewOffset <= 110 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all))
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

                )
            } else {
                // Fallback on earlier versions
            }
                               

        }.onDisappear() {
            let defaults = UserDefaults.standard
            self.showingSettingsView = false
            defaults.set(self.uniformlistshows, forKey: "savedtoggleview")
            self.showpopup = false
        }
    }
    
    func getcompletedAssignments() -> Bool {
        for assignment in assignmentlist {
            if (assignment.completed == true && assignment.grade == 0) {
                return true;
            }
        }
        return false
    }
}
 
 
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
        return HomeView().environment(\.managedObjectContext, context).environmentObject(AddTimeSubassignment()).environment(\.managedObjectContext, context).environmentObject(ActionViewPresets()).environment(\.managedObjectContext, context).environmentObject(AddTimeSubassignmentBacklog()).environment(\.managedObjectContext, context)
    }
}
