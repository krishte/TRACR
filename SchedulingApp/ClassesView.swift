//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI

class Classcool: Identifiable {
    var name: String = ""
    var attentionspan: Int = 0
    var tolerance: Int = 0
    var color: Color = Color.blue
    var assignmentlist: [Assignment] = []
    
    init(name: String, attentionspan: Int, tolerance: Int, color: Color, assignmentlist: [Assignment])
    {
        self.name = name
        self.attentionspan = attentionspan
        self.tolerance = tolerance
        self.color = color
        self.assignmentlist = assignmentlist
    }
}

class Assignment: Identifiable {
    var subject: String = ""
    var name: String = ""
    var type: String = ""
    var duedate: String = ""
    var totaltime: Int = 0
    var progress: Int = 0
    var timeleft: Int = 0
    var subassigmentlist: [SubAssignment] = []
    
    
    init(subject: String, name: String, type: String, duedate: String, totaltime: Int, progress: Int, timeleft: Int, subsylist: [SubAssignment])
    {
        self.subject = subject
        self.name = name
        self.type = type
        self.duedate = duedate
        self.totaltime = totaltime
        self.progress = progress
        self.timeleft = timeleft
        self.subassigmentlist = subsylist
        
    }
    
}

class SubAssignment: Identifiable {
    var startdatetime: String = ""
    var enddatetime: String = ""
    
    init(startdatetime: String, enddatetime: String)
    {
        self.startdatetime = startdatetime
        self.enddatetime = enddatetime
    }

}


struct ClassView: View {
    var classcool: Classcool
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text(classcool.name)
                
            }.background(classcool.color)
            Spacer()
            Text(String(classcool.assignmentlist.count))
        }
    }
}

struct DetailView: View {
    var classcool: Classcool
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).foregroundColor(classcool.color)
            
            Text("Tolerance: " + String(classcool.tolerance))
            
            Text("Attention Span: " + String(classcool.attentionspan))
        }
    }
}

struct ClassesView: View {

    
    var classlist = [
        Classcool(name: "German", attentionspan: 5, tolerance: 4, color: Color("one"), assignmentlist: []),
        Classcool(name: "Math", attentionspan: 4, tolerance: 3,color: Color("two"), assignmentlist: []),
        Classcool(name: "English", attentionspan: 1, tolerance: 2, color: Color("three"), assignmentlist: [])
           
        
    
    ]
    var globalassignmentlist: [Assignment] = []
    
    var body: some View {
         GeometryReader { geometry in
             NavigationView{
                List(self.classlist) { classcool in
                   NavigationLink(destination: DetailView(classcool: classcool)) {
                       ClassView(classcool:classcool)
                       }
                 }
                 .navigationBarItems(
                    leading:
                        HStack(spacing: geometry.size.width / 4.2) {
                            Button(action: {print("settings button clicked")}) {
                                Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }.padding(.leading, 2.0);
                        
                            Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                            Button(action: {print("add button clicked")}) {
                                Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }
                    }.padding(.top, -11.0)).navigationBarTitle(Text("Classes"))
                    
             }
        }
        
        
        
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        ClassesView()
    }
}
