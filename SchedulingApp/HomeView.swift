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
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>

    @Binding var NewClassPresenting: Bool
    @State private var classgroupnameindex = 0
    @State private var classnameindex = 0
    @State private var classlevelindex = 0
    @State private var classtolerance: Int64 = 5

    let subjectgroups = ["Group 1: Language and Literature", "Group 2: Language Acquisition", "Group 3: Individuals and Societies", "Group 4: Sciences", "Group 5: Mathematics", "Group 6: The Arts", "Extended Essay", "Theory of Knowledge"]
    
    let groups = [["English A: Literature", "English A: Language and Literatue"], ["German B", "French B", "German A: Literature", "German A: Language and Literatue", "French A: Literature", "French A: Language and Literatue"], ["Geography", "History", "Economics", "Psychology", "Global Politics"], ["Biology", "Chemistry", "Physics", "Computer Science", "Design Technology", "Environmental Systems and Societies", "Sport Science"], ["Mathematics: Analysis and Approaches", "Mathematics: Applications and Interpretation"], ["Music", "Visual Arts", "Theatre" ], ["Extended Essay"], ["Theory of Knowledge"]]
    
    let colorsa = ["one", "two", "three", "four", "five"]
    let colorsb = ["six", "seven", "eight", "nine", "ten"]
    let colorsc = ["eleven", "twelve", "thirteen", "fourteen", "fifteen"]
    
    @State private var coloraselectedindex: Int? = 0
    @State private var colorbselectedindex: Int?
    @State private var colorcselectedindex: Int?
    
    @State private var createclassallowed = true
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $classgroupnameindex, label: Text("Subject Group: ")) {
                        ForEach(0 ..< subjectgroups.count, id: \.self) { indexg in
                            Text(self.subjectgroups[indexg]).tag(indexg)
                        }
                    }
                    
                        if classgroupnameindex == 0 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[0].count, id: \.self) { index1 in
                                    Text(self.groups[0][index1]).tag(index1)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 1 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[1].count, id: \.self) { index2 in
                                    Text(self.groups[1][index2]).tag(index2)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 2 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[2].count, id: \.self) { index2 in
                                    Text(self.groups[2][index2]).tag(index2)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 3 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[3].count, id: \.self) { index3 in
                                    Text(self.groups[3][index3]).tag(index3)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 4 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[4].count, id: \.self) { index4 in
                                    Text(self.groups[4][index4]).tag(index4)
                                }
                            }
                        }
                                
                        else if classgroupnameindex == 5 {
                            Picker(selection: $classnameindex, label: Text("Subject: ")) {
                                ForEach(0 ..< groups[5].count, id: \.self) { index5 in
                                    Text(self.groups[5][index5]).tag(index5)
                                }
                            }
                        }
                    
                    if classgroupnameindex != 6 && classgroupnameindex != 7 {
                        Picker(selection: $classlevelindex, label: Text("Level")) {
                            Text("SL").tag(0)
                            Text("HL").tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section {
                    Stepper(value: $classtolerance,
                        in: 1...10,
                        label: {
                            Text("Tolerance: \(classtolerance)")
                    })
                }
                
                Section {
                    HStack {
                        Text("Color:")
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexa in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsa[colorindexa])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                            , lineWidth: (self.coloraselectedindex == colorindexa ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = colorindexa
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = nil
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexb in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsb[colorindexb])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                        , lineWidth: (self.colorbselectedindex == colorindexb ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = colorindexb
                                        self.colorcselectedindex = nil
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(0 ..< 5) { colorindexc in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(self.colorsc[colorindexc])).frame(width: 25, height: 25)
                                        RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black
                                    , lineWidth: (self.colorcselectedindex == colorindexc ? 3 : 1)).frame(width: 25, height: 25)
                                    }.onTapGesture {
                                        self.coloraselectedindex = nil
                                        self.colorbselectedindex = nil
                                        self.colorcselectedindex = colorindexc
                                    }
                                }
                            }
                        }
                    }.padding(.vertical, 10)
                }
                
                Section {
                    Button(action: {
                        let testname = self.classgroupnameindex != 6 && self.classgroupnameindex != 7 ? "\(self.groups[self.classgroupnameindex][self.classnameindex]) \(["SL", "HL"][self.classlevelindex])" : "\(self.groups[self.classgroupnameindex][self.classnameindex])"
                        
                        self.createclassallowed = true
                        
                        for classity in self.classlist {
                            if classity.name == testname {
                                print("sdfds")
                                self.createclassallowed = false
                            }
                        }

                        if self.createclassallowed {
                            let newClass = Classcool(context: self.managedObjectContext)
                            print(self.classtolerance)
                            print(self.classnameindex)
                            newClass.attentionspan = Int64(Int.random(in: 1...10))
                            newClass.tolerance = self.classtolerance
                            newClass.name = testname
                            newClass.assignmentnumber = 0
                            if self.coloraselectedindex != nil {
                                newClass.color = self.colorsa[self.coloraselectedindex!]
                            }
                            else if self.colorbselectedindex != nil {
                                newClass.color = self.colorsb[self.colorbselectedindex!]
                            }
                            else if self.colorcselectedindex != nil {
                                newClass.color = self.colorsc[self.colorcselectedindex!]
                            }

                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            self.NewClassPresenting = false
                        }
                            
                        else {
                            print("Class with Same Name Exists; Change Name")
                            self.showingAlert = true
                        }
                    }) {
                        Text("Add Class")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Class Already Exists"), message: Text("Change Class"), dismissButton: .default(Text("Continue")))}
                }
            }.navigationBarItems(trailing: Button(action: {self.NewClassPresenting = false}, label: {Text("Cancel")})).navigationBarTitle("Add Class", displayMode: .inline)
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
                            IndividualSubassignmentView(subassignment2: subassignment).animation(.spring())//.shadow(radius: 10)
                                

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
    
    @FetchRequest(entity: Subassignmentnew.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Subassignmentnew.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignmentnew>
    
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    
    var starttime, endtime, color, name, duedate: String
    var actualstartdatetime, actualenddatetime, actualduedate: Date
    @State var isDragged: Bool = false
    @State var deleted: Bool = false
    @State var deleteonce: Bool = true
    @State var dragoffset = CGSize.zero
    
    init(subassignment2: Subassignmentnew)
    {
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

    }
        
    var body: some View {
        ZStack {
            VStack {
               if (isDragged) {
                   ZStack {
                       HStack {
                           Rectangle().fill(Color.green) .frame(width: UIScreen.main.bounds.size.width-20).offset(x: UIScreen.main.bounds.size.width-10+self.dragoffset.width)
                       }
                       HStack {
                           Spacer()
                           if (self.dragoffset.width < -110) {
                               Text("Complete").foregroundColor(Color.white).frame(width:100)
                           }
                           else {
                               Text("Complete").foregroundColor(Color.white).frame(width:100).offset(x: self.dragoffset.width + 110)
                           }
                       }
                   }
               }
           }
            VStack {
                Text(self.name).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-50, height: 50, alignment: .topLeading)
                Text(self.starttime + " - " + self.endtime).frame(width: UIScreen.main.bounds.size.width-50,height: 30, alignment: .topLeading)
                Text("Due Date: " + self.duedate).frame(width: UIScreen.main.bounds.size.width-50, height: 30, alignment: .topLeading)
             //   Text(self.actualstartdatetime.description)


                }.padding(10).background(Color(color)).cornerRadius(20).offset(x: self.dragoffset.width).gesture(DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onChanged { value in
                    self.dragoffset = value.translation
                    self.isDragged = true

                    if (self.dragoffset.width > 0) {
                        self.dragoffset = CGSize.zero
                        self.dragoffset.width = 0
                    }
                                        
                    if (self.dragoffset.width < -UIScreen.main.bounds.size.width * 3/4) {
                        self.deleted = true
                    }
                }
                .onEnded { value in
                    self.dragoffset = .zero
                    self.isDragged = false
                    if (self.deleted == true) {
                        if (self.deleteonce == true) {
                            self.deleteonce = false
                            for (_, element) in self.assignmentlist.enumerated() {
                                if (element.name == self.name)
                                {
                                    let diffComponents = Calendar.current.dateComponents([.hour], from: self.actualstartdatetime, to: self.actualenddatetime)
                                    let hours = diffComponents.hour!
                                    element.timeleft -= Int64(hours)
                                    element.progress = Int64((Double(element.totaltime - element.timeleft)/Double(element.totaltime)) * 100)
                                    if (element.timeleft == 0)
                                    {
                                        element.completed = true
                                        for classity in self.classlist {
                                            if (classity.name == element.subject)
                                            {
                                                classity.assignmentnumber -= 1
                                            }
                                        }
                                    }
                                }
                            }
                            for (index, element) in self.subassignmentlist.enumerated() {
                                if (element.startdatetime == self.actualstartdatetime && element.assignmentname == self.name)
                                {
                                    self.managedObjectContext.delete(self.subassignmentlist[index])
                                }
                            }
                            do {
                                try self.managedObjectContext.save()
                                print("Class made ")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }).animation(.spring())
        }.padding(10)
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
                }
            
                Image("Tracr").resizable().scaledToFit().frame(width: UIScreen.main.bounds.size.width / 4)

                Button(action: {self.NewAssignmentPresenting.toggle()}) {
                    Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: UIScreen.main.bounds.size.width / 12)
                }.contextMenu{
                    Button(action: {self.NewAssignmentPresenting.toggle()}) {
                        Text("Assignment")
                        Image(systemName: "paperclip")
                    }.sheet(isPresented: $NewAssignmentPresenting, content: { NewAssignmentModalView().environment(\.managedObjectContext, self.managedObjectContext)})
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
                    }.sheet(isPresented: $NewFreetimePresenting, content: { NewFreetimeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
                    Button(action: {self.NewGradePresenting.toggle()}) {
                        Text("Grade")
                        Image(systemName: "percent")
                    }.sheet(isPresented: $NewGradePresenting, content: { NewGradeModalView().environment(\.managedObjectContext, self.managedObjectContext)})
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
