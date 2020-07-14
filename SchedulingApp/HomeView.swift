//
//  HomeView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

struct NewAssignmentModalView: View {
    var body: some View {
        Text("new assignment")
    }
}

struct NewClassModalView: View {
    var body: some View {
        Text("new class")
    }
}

struct NewOccupiedtimeModalView: View {
    var body: some View {
        Text("new occupied time")
    }
}

struct NewFreetimeModalView: View {
    var body: some View {
        Text("new free time")
    }
}

struct NewGradeModalView: View {
    var body: some View {
        Text("new grade")
    }
}

struct SubAssignmentView: View {
    var subassignment: Subassignment
    
    var body: some View {
        VStack{
            Text("subassignment")
        }
    }
}

struct HomeBodyView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Subassignment.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Subassignment.startdatetime, ascending: true)])
    
    var subassignmentlist: FetchedResults<Subassignment>
    
    var datesfromtoday: [Date] = []
    var daytitlesfromtoday: [String] = []
    var datenumbersfromtoday: [String] = []
    
    @State var nthdayfromnow: Int = 0
    
    init() {
        let daytitleformatter = DateFormatter()
        daytitleformatter.dateFormat = "EEEE, d MMMM"
        
        let datenumberformatter = DateFormatter()
        datenumberformatter.dateFormat = "d"

        for eachdayfromtoday in 0...27 {
            self.datesfromtoday.append(eachdayfromtoday == 0 ? Date() : Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday))))
            
            self.daytitlesfromtoday.append(daytitleformatter.string(from: Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday)))))
            
            self.datenumbersfromtoday.append(datenumberformatter.string(from: Date(timeIntervalSinceNow: TimeInterval((86400 * eachdayfromtoday)))))
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(datenumbersfromtoday.indices) { datenumberindex in
                        ZStack {
                            Circle().fill(datenumberindex == self.nthdayfromnow ? Color("datenumberred") : Color.white).frame(width: 50, height: 50)
                            Circle().stroke(Color.black).frame(width: 50, height: 50)
                            Text(self.datenumbersfromtoday[datenumberindex]).font(.system(size: 20)).fontWeight(.regular)
                        }.onTapGesture {
                            self.nthdayfromnow = datenumberindex
                        }
                    }
                }.padding(.horizontal, 15).frame(height: 55)
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
                Text("SubAssignments bubbles go here")
            }
            
            Spacer()
        }
    }
}

struct HomeView: View {
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
                            }.sheet(isPresented: $NewAssignmentPresenting, content: {NewAssignmentModalView()})
                            Button(action: {self.NewClassPresenting.toggle()}) {
                                Text("Class")
                                Image(systemName: "list.bullet")
                            }.sheet(isPresented: $NewClassPresenting, content: {NewClassModalView()})
                            Button(action: {self.NewOccupiedtimePresenting.toggle()}) {
                                Text("Occupied Time")
                                Image(systemName: "clock.fill")
                            }.sheet(isPresented: $NewOccupiedtimePresenting, content: {NewOccupiedtimeModalView()})
                            Button(action: {self.NewFreetimePresenting.toggle()}) {
                                Text("Free Time")
                                Image(systemName: "clock")
                            }.sheet(isPresented: $NewFreetimePresenting, content: {NewFreetimeModalView()})
                            Button(action: {self.NewGradePresenting.toggle()}) {
                                Text("Grade")
                                Image(systemName: "percent")
                            }.sheet(isPresented: $NewGradePresenting, content: {NewGradeModalView()})
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
