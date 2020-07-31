//
//  Master.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct MasterStruct:View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.subject, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    
    
    
    
    let types = ["Test", "Homework", "Presentation", "Essay", "Study", "Exam", "Report", "Essay", "Presentation", "Essay"]
    let duedays = [7, 2, 3, 8, 180, 14, 1, 4 , 300, 150]
    let duetimes = ["day", "day", "day", "night", "day", "day", "day", "day", "day", "day"]
    let totaltimes = [600, 90, 240, 210, 4620, 840, 120, 300, 720, 240]
    let names = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let classnames = ["Math", "Math", "German", "English", "Physics" , "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let colors = ["one", "one", "two", "three" , "four", "four", "five", "six", "seven", "eight"]
    
    let bulks = [true, true, true, false, false, false, false, false]
    let classnameactual = ["Math", "German", "English", "Physics", "Chemistry", "Economics", "Theory of Knowledge", "Extended Essay"]
    let tolerances = [9, 3, 4, 9, 6, 8, 2, 7]
    let assignmentnumbers = [2, 1, 1, 2, 1, 1, 1, 1]
    let classcolors = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: Date())
    }
    
    init() {
        print(startOfDay)
        master()
    }
    
    func master() -> Void {
        print("epic success")
         
        for i in (0...7) {
            let newClass = Classcool(context: self.managedObjectContext)
            newClass.attentionspan = 0
            newClass.tolerance = Int64(tolerances[i])
            newClass.name = classnameactual[i]
            newClass.assignmentnumber = 0
            newClass.color = classcolors[i]
            
            do {
                try self.managedObjectContext.save()
                print("Class made")
            } catch {
                print(error.localizedDescription)
            }
        }
        for i in (0...9) {
            let newAssignment = Assignment(context: self.managedObjectContext)
            newAssignment.name = String(names[i])
            newAssignment.duedate = startOfDay.addingTimeInterval(TimeInterval(7200 + 86400*duedays[i]))
            if (duetimes[i] == "night")
            {
                newAssignment.duedate.addTimeInterval(79200)
            }
            else
            {
                newAssignment.duedate.addTimeInterval(28800)
            }
            
            newAssignment.totaltime = Int64(totaltimes[i])
            newAssignment.subject = classnames[i]
            newAssignment.timeleft = newAssignment.totaltime
            newAssignment.progress = 0
            newAssignment.grade = 0
            newAssignment.completed = false
            newAssignment.type = types[i]

            for classity in self.classlist {
                if (classity.name == newAssignment.subject) {
                    classity.assignmentnumber += 1
                    newAssignment.color = classity.color
                    do {
                        try self.managedObjectContext.save()
                        print("Class number changed")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }

    }
    var body: some View {
        EmptyView()
    }

}

