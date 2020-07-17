//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct NewAssignmentModalView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        Text("new assignment")
    }
}

struct NewClassModalView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
     @State private var classname: String = ""
     @State private var classtolerance: Int64 = 5



    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Firstname", text: $classname)
                }
                Section {
                    Stepper(value: $classtolerance,
                        in: 1...10,
                        label: {
                            Text("Tolerance: \(classtolerance)")
                    })
                    
                }
                Section {
                    Button(action: {
                        let newClass = Classcool(context: self.managedObjectContext)
                        print(self.classtolerance)
                        print(self.classname)
                        newClass.attentionspan = Int64.random(in: 0 ... 10)
                        newClass.tolerance = self.classtolerance
                        newClass.name = self.classname
                        newClass.assignmentnumber = 0
                        newClass.color = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"].randomElement()!
                        do {
                         try self.managedObjectContext.save()
                        } catch {
                         print(error.localizedDescription)
                         }
                        
                    }) {
                        Text("Add Class")
                    }
                }
            }.navigationBarTitle("Add Class")
        }
    }
}

struct NewOccupiedtimeModalView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        Text("new occupied time")
    }
}

struct NewFreetimeModalView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        Text("new free time")
    }
}

struct NewGradeModalView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        Text("new grade")
    }
}

struct SubAssignmentView: View {
     @Environment(\.managedObjectContext) var managedObjectContext
    var subassignment: Subassignmentnew
    
    var body: some View {
        VStack{
            Text("subassignment")
        }
    }
}

struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Subassignmentnew.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    var datesfromtoday: [Date] = []
    var daytitlesfromtoday: [String] = []
    var datenumbersfromtoday: [String] = []
    var formatteryear: DateFormatter
    var formattermonth: DateFormatter
    var formatterday: DateFormatter
    
    @State var nthdayfromnow: Int = 0
    
    init() {
        let daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
        
        let datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"
        
        formatteryear = DateFormatter()
        formatteryear.dateFormat = "yyyy"
        
        formattermonth = DateFormatter()
        formattermonth.dateFormat = "MM"
        
        formatterday = DateFormatter()
        formatterday.dateFormat = "dd"
        
        for eachdayfromtoday in 0...27 {
            self.datesfromtoday.append(eachdayfromtoday == 0 ? Date() : Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday))))
            
            self.daytitlesfromtoday.append(daytitleformatter.string(from: Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday)))))
            
            self.datenumbersfromtoday.append(datenumberformatter.string(from: Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday)))))
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: (UIScreen.main.bounds.size.width / 29)) {
                    ForEach(datenumbersfromtoday.indices) { datenumberindex in
                        ZStack {
                            Circle().fill(datenumberindex == self.nthdayfromnow ? Color("datenumberred") : Color.white).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3)
                            Circle().stroke(Color.black).frame(width: (UIScreen.main.bounds.size.width / 29) * 3, height: (UIScreen.main.bounds.size.width / 29) * 3)
                            Text(self.datenumbersfromtoday[datenumberindex]).font(.system(size: (UIScreen.main.bounds.size.width / 29) * (4 / 3))).fontWeight(.regular)
                        }.onTapGesture {
                            self.nthdayfromnow = datenumberindex
                        }
                    }
                }.padding(.horizontal, (UIScreen.main.bounds.size.width / 29)).frame(height: 1.1 * (UIScreen.main.bounds.size.width / 29) * 3)
            }
            
            Text(daytitlesfromtoday[self.nthdayfromnow]).font(.title).fontWeight(.medium).padding(.top, 5).padding(.bottom, 15)
            
            VStack {
            //THE SUBASSIGNMENT BUBBLES GO HERE
            //                ForEach(subassignmentlist) {
            //                    subassignment in
            //                    if (subassignment.end.timeIntervalSinceDate() == self.classcool.name) {
            //                            SubAssignmentView(subassignment: subassignment)
            //                    }
            //                }
                Text("SubAssignments: " + String(subassignmentlist.count))
              
                ScrollView {
                    ForEach(subassignmentlist) {
                        
                        subassignment in
                        
                        if ( Calendar.current.isDate(self.datesfromtoday[self.nthdayfromnow], equalTo: subassignment.startdatetime, toGranularity: .day))
                        {
                            VStack {
                                IndividualSubassignmentView(subassignment2: subassignment).animation(.spring()).shadow(radius: 10)
                                
                            }.padding(10)
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

struct IndividualSubassignmentView: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assignment.duedate, ascending: true)])
    
    var assignmentlist: FetchedResults<Assignment>
    var starttime, endtime, color, name: String
    var actualstartdatetime: Date

    
    init(subassignment2: Subassignmentnew)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.starttime = formatter.string(from: subassignment2.startdatetime)
        self.endtime = formatter.string(from: subassignment2.enddatetime)
        self.color = subassignment2.color
        self.name = subassignment2.assignmentname
        self.actualstartdatetime = subassignment2.startdatetime

    }
        
    var body: some View {
        VStack {
            Text(self.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
            Text(self.starttime + " - " + self.endtime).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
         //   Text(self.actualstartdatetime.description)


        }.padding(10).background(Color(color)).cornerRadius(20)

    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var NewAssignmentPresenting = false
    @State var NewClassPresenting = false
    @State var NewOccupiedtimePresenting = false
    @State var NewFreetimePresenting = false
    @State var NewGradePresenting = false

    var body: some View {
        VStack {
            HStack(spacing: UIScreen.main.bounds.size.width / 4.2) {
                Button(action: {print("settings button clicked")}) {
                    Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                }.padding(.leading, 2.0);
            
                Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4);

                Button(action: {self.NewAssignmentPresenting.toggle()}){
                    Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                }.contextMenu{
                    VStack(alignment: .trailing) {
                        VStack(alignment: .trailing, spacing: 10) {
                            Button(action: {self.NewAssignmentPresenting.toggle()}) {
                                Text("Assignment")
                                Image(systemName: "paperclip")
                            }.sheet(isPresented: $NewAssignmentPresenting, content: {NewAssignmentModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewClassPresenting.toggle()}) {
                                Text("Class")
                                Image(systemName: "list.bullet")
                            }.sheet(isPresented: $NewClassPresenting, content: {
                                NewClassModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                Text("Occupied Time")
                                Image(systemName: "clock.fill")
                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: {NewOccupiedtimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewFreetimePresenting.toggle()}) {
                                Text("Free Time")
                                Image(systemName: "clock")
                            }.sheet(isPresented: $NewFreetimePresenting, content: {NewFreetimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                            Button(action: {self.NewGradePresenting.toggle()}) {
                                Text("Grade")
                                Image(systemName: "percent")
                            }.sheet(isPresented: $NewGradePresenting, content: {NewGradeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                        }.padding().background(Color("add_overlay_bg")).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("add_overlay_border"), lineWidth: 1)
                        ).shadow(color: Color.black.opacity(0.1), radius: 20, x: -7, y: 7).padding(.leading, 61)
                        Spacer()
                    }
                }
            }.padding(.bottom, 18)
            HomeBodyView()
            
            
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
             let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
          
          return HomeView().environment(\.managedObjectContext, context)
    }
}
