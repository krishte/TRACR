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
                            Button(action: {
                                    self.classlist.count > 0 ? self.NewAssignmentPresenting.toggle() : self.noClassesAlert.toggle()
                                dateselector.dateIndex = self.datenumberindices[index]
                            }) {
                                Text("Assignment")
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
                
            }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView(NewAssignmentPresenting: self.$NewAssignmentPresenting, selectedClass: 0, preselecteddate: dateselector.dateIndex).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)}).alert(isPresented: $noClassesAlert) {
                Alert(title:  Text("No Classes Added"), message: Text("Add a Class First"))
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
    
    @FetchRequest(entity: AddTimeLog.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AddTimeLog.name, ascending: true)])
    var addtimeloglist: FetchedResults<AddTimeLog>
    
    @EnvironmentObject var addTimeSubassignment: AddTimeSubassignment
    @EnvironmentObject var actionViewPresets: ActionViewPresets

    @EnvironmentObject var masterRunning: MasterRunning
    
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
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(addTimeSubassignment.subassignmentcolor)).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
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
            //Storing the AddTime Transactions
            let newAddTimeLog = AddTimeLog(context: self.managedObjectContext)

            newAddTimeLog.name = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentname
            newAddTimeLog.length = Int64(addTimeSubassignment.subassignmentlength)
            newAddTimeLog.color = self.subassignmentlist[addTimeSubassignment.subassignmentindex].color
            newAddTimeLog.starttime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].startdatetime
            newAddTimeLog.endtime = self.subassignmentlist[addTimeSubassignment.subassignmentindex].enddatetime
            newAddTimeLog.date = self.subassignmentlist[addTimeSubassignment.subassignmentindex].assignmentduedate
            newAddTimeLog.completionpercentage = addTimeSubassignment.subassignmentcompletionpercentage
            
            //Some Adjustments
            actionViewPresets.actionViewOffset = UIScreen.main.bounds.size.width
            actionViewPresets.actionViewHeight = 1
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
//                actionViewPresets.actionViewType = ""
//            }
            
            //Deleting the Subsasignment
            self.managedObjectContext.delete(self.subassignmentlist[addTimeSubassignment.subassignmentindex])
            
            //Changing the Assignment
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
                            RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color(addTimeSubassignmentBacklog.backlogList[subassignmentindex]["subassignmentcolor"] ?? "datenumberred")).frame(width: 12, height: 12).overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black, lineWidth: 0.6)
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
        
        //AddTimeActionViews for each task in the backlog
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
                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(addTimeSubassignmentBacklog.backlogList[0]["subassignmentcolor"] ?? "one")).frame(width: 30, height: 30).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 0.6)
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
                //Storing the AddTime Transactions
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
                masterRunning.displayText = true
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

struct ActionView: View {
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    @EnvironmentObject var addTimeSubassignmentBacklog: AddTimeSubassignmentBacklog
    
    @Environment(\.managedObjectContext) var managedObjectContext
 
    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    func initialize() {
        addTimeSubassignmentBacklog.backlogList = []

        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"

        let shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
        
        var longDueSubassignment = false
        
        for (index, subassignment) in subassignmentlist.enumerated() {
            if subassignment.enddatetime < Date() {
                var tempAddTimeSubassignment: [String: String] = ["throwawaykey": "throwawayvalue"]

                tempAddTimeSubassignment["subassignmentname"] = subassignment.assignmentname
                tempAddTimeSubassignment["subassignmentlength"] = String(Calendar.current.dateComponents([.minute], from: subassignment.startdatetime, to: subassignment.enddatetime).minute!)
                tempAddTimeSubassignment["subassignmentcolor"] = subassignment.color
                tempAddTimeSubassignment["subassignmentstarttimetext"] = timeformatter.string(from: subassignment.startdatetime)
                tempAddTimeSubassignment["subassignmentendtimetext"] = timeformatter.string(from: subassignment.enddatetime)
                tempAddTimeSubassignment["subassignmentdatetext"] = shortdateformatter.string(from: subassignment.startdatetime)

                addTimeSubassignmentBacklog.backlogList.append(tempAddTimeSubassignment)
                
                if Date(timeInterval: 86400, since: subassignment.enddatetime) < Date() {
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
    }
    
    var body: some View {
        VStack {
            if actionViewPresets.actionViewType == "SubassignmentAddTimeAction" {
                SubassignmentAddTimeAction()
            }
            
            else if actionViewPresets.actionViewType == "SubassignmentBacklogAction" {
                SubassignmentBacklogAction()
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
    
    @State var nthdayfromnow: Int = Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day!
    
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
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    init(uniformlistshows: Binding<Bool>, NewAssignmentPresenting2: Binding<Bool>) {
        self._uniformlistviewshows = uniformlistshows
        self._NewAssignmentPresenting = NewAssignmentPresenting2
 
        self._lastnthdayfromnow = self._nthdayfromnow
        
        daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
      //  daytitleformatter.timeZone = TimeZone(secondsFromGMT: 7200)
        
        datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"
     //   datenumberformatter.timeZone = TimeZone(secondsFromGMT: 7200)
        
        formatteryear = DateFormatter()
        formatteryear.dateFormat = "yyyy"
        
        formattermonth = DateFormatter()
        formattermonth.dateFormat = "MM"
        
        formatterday = DateFormatter()
        formatterday.dateFormat = "dd"
      //  formatterday.timeZone = TimeZone(secondsFromGMT: 7200)
        hourformatter = DateFormatter()
        minuteformatter = DateFormatter()
        self.hourformatter.dateFormat = "HH"
        self.minuteformatter.dateFormat = "mm"
        timeformatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
     //   timeformatter.timeZone = TimeZone(secondsFromGMT: 7200)
        //timeformatter.timeZone = TimeZone(secondsFromGMT: 0)
        shortdateformatter = DateFormatter()
        shortdateformatter.timeStyle = .none
        shortdateformatter.dateStyle = .short
      //  shortdateformatter.timeZone = TimeZone(secondsFromGMT: 7200)
     //   shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
       // self._selecteddaytitle = State(initialValue: nthdayfromnow)
        self.selectedColor  = "one"
        
        let lastmondaydate = Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!)
        
       // print(lastmondaydate.description)
        
        for eachdayfromlastmonday in 0...27 {
            self.datesfromlastmonday.append(Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate))
            
            self.daytitlesfromlastmonday.append(daytitleformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
            
            self.datenumbersfromlastmonday.append(datenumberformatter.string(from: Date(timeInterval: TimeInterval((86400 * eachdayfromlastmonday)), since: lastmondaydate)))
        }
       // print(self.datesfromlastmonday[21], daytitlesfromlastmonday[21], datenumbersfromlastmonday[21])
        //print(self.datesfromlastmonday[20], daytitlesfromlastmonday[20], datenumbersfromlastmonday[20])
//        for i in 0...27 {
//            print(self.datesfromlastmonday[i], self.daytitlesfromlastmonday[i], self.datenumbersfromlastmonday[i])
//        }
    }
    
    func upcomingDisplayTime() -> String {
//        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        
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
//        let timezoneOffset =  TimeZone.current.secondsFromGMT()

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
    
    var body: some View {
        VStack {
           // Text(String(subassignmentlist.count))
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
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [getNextColor(currentColor: selectedColor), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
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
                            Text("Coming Up:").fontWeight(.semibold).animation(.none)
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
                                    Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 25, alignment: .topLeading)
                                    Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 12)).frame(height:15)
                                    Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                    UpcomingSubassignmentProgressBar(assignment: assignment).frame(height:10)
                                }
                            }
                        }.frame(width: 150)
                    }
                }.padding(10)
            }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10).animation(.spring())

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
                                            IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: false, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment).padding(.top, CGFloat(Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: subassignment.startdatetime), to: subassignment.startdatetime).second!).truncatingRemainder(dividingBy: 86400)/3600 * 60.35 + 1.3).onTapGesture {
                                                self.subassignmentassignmentname = subassignment.assignmentname
                                                self.selectedColor = subassignment.color
//                                                for subassignment in self.subassignmentlist {
//                                                    print(subassignment.startdatetime.description)
//                                                }
                                            }
                                                //was +122 but had to subtract 2*60.35 to account for GMT + 2
                                        }
                                        if masterRunning.masterRunningNow {
                                            MasterClass()
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
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(LinearGradient(gradient: Gradient(colors: [getNextColor(currentColor: selectedColor), Color(selectedColor)]), startPoint: .leading, endPoint: .trailing))
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
                        }.frame(width:self.subassignmentassignmentname == "" ? UIScreen.main.bounds.size.width-60:150).animation(.none)
//                        if (self.subassignmentassignmentname == "")
//                        {
//                            Spacer().frame(width: 150)
//                        }
                        if self.subassignmentassignmentname != "" {
                            Spacer().frame(width: 10)
                            Divider().frame(width: 1).background(Color.black)
                            Spacer().frame(width: 20)
                            VStack(alignment: .leading) {
                                ForEach(self.assignmentlist) { assignment in
                                    if (assignment.name == self.subassignmentassignmentname) {
                                      //  Text(assignment.name).font(.system(size: 15)).fontWeight(.bold).multilineTextAlignment(.leading).lineLimit(nil).frame(width: 150, height: 40, alignment: .topLeading)

                                        Text("Due Date: " + self.shortdateformatter.string(from: assignment.duedate)).font(.system(size: 15)).fontWeight(.bold).frame(height:40)
                                        Text("Type: " + assignment.type).font(.system(size: 12)).frame(height:15)
                                        Text("Work Left: \(assignment.timeleft / 60)h \(assignment.timeleft % 60)m").font(.system(size: 12)).frame(height: 15)
                                        UpcomingSubassignmentProgressBar(assignment: assignment).frame(height: 10)
                                        Spacer().frame(height: 10)
                                    }
                                }
                            }.frame(width: 150)
                        }
                        
                    }.padding(10)
                }.frame(width: UIScreen.main.bounds.size.width-30, height: 100).padding(10).animation(.spring())
                ScrollView {


                ForEach(0 ..< daytitlesfromlastmonday.count) { daytitle in
                    if (Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day! <= daytitle)
                    {
                        HStack {
                            Spacer().frame(width: 10)
                            Text(self.daytitlesfromlastmonday[daytitle]).font(.system(size: 20)).foregroundColor(daytitle == Calendar.current.dateComponents([.day], from: Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!) > Date() ? Date(timeInterval: TimeInterval(-518400), since: Date().startOfWeek!) : Date(timeInterval: TimeInterval(86400), since: Date().startOfWeek!), to: Date()).day! ? Color.blue : Color("blackwhite")).fontWeight(.bold)
                            Spacer()
                        }.frame(width: UIScreen.main.bounds.size.width, height: 40).background(Color("add_overlay_bg"))
                        SubassignmentListView(daytitle: self.daytitlesfromlastmonday[daytitle],  daytitlesfromlastmonday: self.daytitlesfromlastmonday, datesfromlastmonday: self.datesfromlastmonday, subassignmentassignmentname: self.$subassignmentassignmentname, selectedcolor: self.$selectedColor, showeditassignment: self.$showeditassignment, selectededitassignment: self.$sheetnavigator.selectededitassignment).animation(.spring())
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
                    EditAssignmentModalView(NewAssignmentPresenting: self.$showeditassignment, selectedassignment: self.getassignmentindex(), assignmentname: self.assignmentlist[self.getassignmentindex()].name, timeleft: Int(self.assignmentlist[self.getassignmentindex()].timeleft), duedate: self.assignmentlist[self.getassignmentindex()].duedate, iscompleted: self.assignmentlist[self.getassignmentindex()].completed, gradeval: Int(self.assignmentlist[self.getassignmentindex()].grade), assignmentsubject: self.assignmentlist[self.getassignmentindex()].subject).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)})
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
       // shortdateformatter.timeZone = TimeZone(secondsFromGMT: 0)
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
                IndividualSubassignmentView(subassignment2: subassignment, fixedHeight: true, showeditassignment: self.$showeditassignment, selectededitassignment: self.$selectededitassignment).onTapGesture {
                    selectedcolor = subassignment.color
                    subassignmentassignmentname = subassignment.assignmentname
                }                        //was +122 but had to subtract 2*60.35 to account for GMT + 2
            }
            
        }.animation(.spring())
        
        if masterRunning.masterRunningNow {
            MasterClass()
        }
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
    
    init(subassignment2: Subassignmentnew, fixedHeight: Bool, showeditassignment: Binding<Bool>, selectededitassignment: Binding<String>) {

        self._showeditassignment = showeditassignment
        self._selectededitassignment = selectededitassignment
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
      //  formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.starttime = formatter.string(from: subassignment2.startdatetime)
       // print(subassignment2.startdatetime.description, self.starttime)
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
                            Rectangle().fill(Color("fourteen")) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +    CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).offset(x: self.fixedHeight ? UIScreen.main.bounds.size.width - 10 + self.dragoffset.width : UIScreen.main.bounds.size.width-30+self.dragoffset.width)
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
                            Rectangle().fill(Color.gray) .frame(width: UIScreen.main.bounds.size.width-20, height: fixedHeight ? 70 : 58 +  CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).offset(x: self.fixedHeight ? screenval+10+self.dragoffset.width : -UIScreen.main.bounds.size.width-20+self.dragoffset.width)
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
                if (fixedHeight)
                {
                    Text(self.name).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
                }
                else
                {
                    Text(self.name).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).fontWeight(.bold).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading).padding(.top, 5)
                }
                if (!fixedHeight)
                {
                    Text(self.starttime + " - " + self.endtime).font(.system(size:  38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35) < 40 ? 12 : 15)).frame(width: self.fixedHeight ? UIScreen.main.bounds.size.width-40 :  UIScreen.main.bounds.size.width-80, alignment: .topLeading)
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
            }.frame(height: fixedHeight ? 50 : 38 + CGFloat(Double(((Double(subassignmentlength)-60)/60))*60.35)).padding(12).background(Color(color)).cornerRadius(10).contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous)).offset(x: self.dragoffset.width).contextMenu {
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
                    
                    //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
//                        self.isDragged = false
//                        self.isDraggedleft = false
                   // }
                    print("drag gesture ended")
                    if (self.incompleted == true) {
                        if (self.incompletedonce == true) {
//                            self.incompletedonce = false
                            print("incompleted")
                            
                            actionViewPresets.actionViewOffset = 0
                            actionViewPresets.actionViewHeight = 280
                            actionViewPresets.actionViewType = "SubassignmentAddTimeAction"
                            addTimeSubassignment.subassignmentname = self.name
                            addTimeSubassignment.subassignmentlength = self.subassignmentlength
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
                                    let minutes = self.subassignmentlength
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
                            
                            masterRunning.masterRunningNow = true
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
    
    @State var noClassesAlert = false
    
    @State var noCompletedAlert = false
    //completed true and grade != 0
    @EnvironmentObject var actionViewPresets: ActionViewPresets
    
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
    
    @EnvironmentObject var masterRunning: MasterRunning
    
    @ViewBuilder
    private func sheetContent() -> some View {
        if (self.sheetNavigator.modalView == .freetime) {
            NewFreetimeModalView(NewFreetimePresenting: self.$NewSheetPresenting).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
        }
        else if (self.sheetNavigator.modalView == .assignment)
        {
            NewAssignmentModalView(NewAssignmentPresenting: self.$NewSheetPresenting, selectedClass: 0, preselecteddate: -1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.masterRunning)
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
                Text("If you are able to read this, please report this as a bug.")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ZStack {
                    
                    NavigationLink(destination: SettingsView(), isActive: self.$showingSettingsView)
                        { EmptyView() }
                    HomeBodyView(uniformlistshows: self.$uniformlistshows, NewAssignmentPresenting2: $NewAssignmentPresenting).padding(.top, -40)               // }
                    
                    
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
