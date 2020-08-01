//
//  Master.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct MasterStruct {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    @FetchRequest(entity: Freetime.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Freetime.startdatetime, ascending: true)])
    var freetimelist: FetchedResults<Freetime>
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    
    
    
    let types = ["Test", "Homework", "Presentation", "Essay", "Study", "Exam", "Report", "Essay", "Presentation", "Essay"]
    let duedays = [7, 2, 3, 8, 180, 14, 1, 4 , 300, 150]
    let duetimes = ["day", "day", "day", "night", "day", "day", "day", "day", "day", "day"]
    let totaltimes = [600, 90, 240, 210, 4620, 840, 120, 300, 720, 2400]
    let names = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let classnames = ["Math", "Math", "German", "English", "Physics" , "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let colors = ["one", "one", "two", "three" , "four", "four", "five", "six", "seven", "eight"]
    
    let bulks = [true, true, true, false, false, false, false, false]
    let classnameactual = ["Math", "German", "English", "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let tolerances = [9, 3, 4, 9, 6, 8, 2, 7]
    let assignmentnumbers = [2, 1, 1, 2, 1, 1, 1, 1]
    let classcolors = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: Date() + 7200)
    }
    
    init() {
        print(startOfDay)
        master()
    }
    
    func master() -> Void {
        print("epic success")
        
        for (index, _) in subassignmentlist.enumerated() {
             self.managedObjectContext.delete(self.subassignmentlist[index])
        }
        var timemonday = 0
        var timetuesday = 0
        var timewednesday = 0
        var timethursday = 0
        var timefriday = 0
        var timesaturday = 0
        var timesunday = 0
        var latestDate = Date(timeIntervalSinceNow: 7200)
        var dateFreeTimeDict = [Date: Int]()
        
        
        for freetime in freetimelist {
            if (freetime.monday)
            {
                timemonday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.tuesday)
            {
                timetuesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.wednesday)
            {
                timewednesday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.thursday)
            {
                timethursday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.friday)
            {
                timefriday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.saturday)
            {
                timesaturday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            if (freetime.sunday)
            {
                timesunday += Calendar.current.dateComponents([.minute], from: freetime.startdatetime, to: freetime.enddatetime).minute!
            }
            
        }
        var generalfreetimelist = [timemonday, timetuesday, timewednesday, timethursday, timefriday, timesaturday, timesunday]
        
        for assignment in assignmentlist {
            latestDate = max(latestDate, assignment.duedate)
        }
        
        let daystilllatestdate = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: 7200), to: latestDate).day!
        
        for i in 0...daystilllatestdate {
            dateFreeTimeDict[Date(timeInterval: TimeInterval(86400*i), since: startOfDay)] = generalfreetimelist[(Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1)]
            print( Date(timeInterval: TimeInterval(86400*i), since: startOfDay).description, (Calendar.current.component(.weekday, from: Date(timeInterval: TimeInterval(86400*i), since: startOfDay)) - 1))
            
        }
        
        
        //
//        for i in (0...7) {
//            let newClass = Classcool(context: self.managedObjectContext)
//            newClass.bulk = bulks[i]
//            newClass.tolerance = Int64(tolerances[i])
//            newClass.name = classnameactual[i]
//            newClass.assignmentnumber = 0
//            newClass.color = classcolors[i]
//
//            do {
//                try self.managedObjectContext.save()
//                print("Class made")
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        for i in (0...9) {
//            let newAssignment = Assignment(context: self.managedObjectContext)
//            newAssignment.name = String(names[i])
//            newAssignment.duedate = startOfDay.addingTimeInterval(TimeInterval(7200 + 86400*duedays[i]))
//            if (duetimes[i] == "night")
//            {
//                newAssignment.duedate.addTimeInterval(79200)
//            }
//            else
//            {
//                newAssignment.duedate.addTimeInterval(28800)
//            }
//
//            newAssignment.totaltime = Int64(totaltimes[i])
//            newAssignment.subject = classnames[i]
//            newAssignment.timeleft = newAssignment.totaltime
//            newAssignment.progress = 0
//            newAssignment.grade = 0
//            newAssignment.completed = false
//            newAssignment.type = types[i]
//
//            for classity in self.classlist {
//                if (classity.name == newAssignment.subject) {
//                    classity.assignmentnumber += 1
//                    newAssignment.color = classity.color
//                    do {
//                        try self.managedObjectContext.save()
//                        print("Class number changed")
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }

    }
    var body: some View {
        EmptyView()
    }

}

