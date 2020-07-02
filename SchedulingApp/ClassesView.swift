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
    var assignmentnumber : Int = 0
    
    init(name: String, attentionspan: Int, tolerance: Int, assignmentnumber: Int)
    {
        self.name = name
        self.attentionspan = attentionspan
        self.tolerance = tolerance
        self.assignmentnumber = assignmentnumber
    }
}

class Assignment: Identifiable {
    var name: String = ""
    var type: String = ""
    var duedate: Int = 0
    var time: Int = 0
    
    init(name: String, type: String, duedate: Int, time: Int)
    {
        self.name = name
        self.type = type
        self.duedate = duedate
        self.time = time
    }
    
}

struct ClassView: View {
    var classcool: Classcool
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text(classcool.name)
                
            }
            Spacer()
            Text(String(classcool.assignmentnumber))
        }
    }
}

struct DetailView: View {
    var classcool: Classcool
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title)
            
            Text("Tolerance: " + String(classcool.tolerance))
            
            Text("Attention Span: " + String(classcool.attentionspan))
        }
    }
}

struct ClassesView: View {
    
    let classlist = [
        Classcool(name: "German", attentionspan: 5, tolerance: 4, assignmentnumber: 4),
        Classcool(name: "Math", attentionspan: 4, tolerance: 3, assignmentnumber: 2),
        Classcool(name: "English", attentionspan: 1, tolerance: 2, assignmentnumber: 3)
           
        
    
    ]
    
    
    var body: some View {
     NavigationView{
          List(classlist) { classcool in
                NavigationLink(destination: DetailView(classcool: classcool)) {
                    ClassView(classcool:classcool)
                }
          }
        
            .navigationBarItems(leading:
             HStack {
             Button(action: {}) {
                Image(systemName: "gear").resizable().scaledToFit().font(.title)
             }.foregroundColor(.black)
              
            },trailing:
         HStack {
             Button(action: {}) {
                 Image(systemName: "plus")
                    .font(.title)
             }.foregroundColor(.black)
            }).navigationBarTitle(Text("Classes"))
     }
 
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        ClassesView()
    }
}
