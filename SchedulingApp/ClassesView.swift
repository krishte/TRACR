//
//  ClassesView.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 6/30/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import SwiftUI


class SubAssignment: Identifiable {
    var startdatetime: String = ""
    var enddatetime: String = ""
    var assignmentname: String = ""
    
    init(startdatetime: String, enddatetime: String, assignmentname: String)
    {
        self.startdatetime = startdatetime
        self.enddatetime = enddatetime
        self.assignmentname = assignmentname
        
    }

}


struct ClassView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    

    var assignmentlist: FetchedResults<Assignment>
    

    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(classcool.name).font(.subheadline).fontWeight(.bold)
                

                    
                        List(assignmentlist) {
                            assignment in
                            if (assignment.subject == self.classcool.name)
                            {
                                Text(assignment.name)
                                
                                
                            }

                           
                        }
                    }
            Spacer()
            Text(String(assignmentlist.count))
        }
    }
}

struct DetailView: View {
    var classcool: Classcool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Assignment.entity(),
                  sortDescriptors: [])
    
    var assignmentlist: FetchedResults<Assignment>
    var assignmentsbyclass: [Assignment] = []
    
    var body: some View {
        VStack {
            Text(classcool.name).font(.title).fontWeight(.bold)
            Spacer()
            Text("Tolerance: " + String(classcool.tolerance))
            Spacer()
            
            List {
                ForEach(assignmentlist) {
                    assignment in
                    if (assignment.subject == self.classcool.name)
                    {
                        Text(assignment.name)
                    }
                }.onDelete { indexSet in
                    for index in indexSet {
                        self.managedObjectContext.delete(self.assignmentlist[index])
                    }
                      do {
                       try self.managedObjectContext.save()
                      } catch {
                       print(error.localizedDescription)
                       }
                    print("Assignment deleted")
                }
            }
        }
    }
}

struct ClassesView: View {

    
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Classcool.entity(),
                  sortDescriptors: [])
    
    var classlist: FetchedResults<Classcool>
//
//    var classlist: [Classcool] = [
//        Classcool(name: "German", attentionspan: 5, tolerance: 4, color: Color("one"), assignmentlist: []),
//        Classcool(name: "Math", attentionspan: 4, tolerance: 3,color: Color("two"), assignmentlist: []),
//        Classcool(name: "English", attentionspan: 1, tolerance: 2,color: Color("three"), assignmentlist: [])
//
//
//
//    ]

    var body: some View {
         GeometryReader { geometry in
             NavigationView{
                List {
                    ForEach(self.classlist) {
                      classcool in
                      NavigationLink(destination: DetailView(classcool: classcool )) {
                        ClassView(classcool: classcool)
                      }
                    }.onDelete { indexSet in
                    for index in indexSet {
                        self.managedObjectContext.delete(self.classlist[index])
                    }
                  do {
                   try self.managedObjectContext.save()
                   print("Class made")
                  } catch {
                   print(error.localizedDescription)
                   }
                print("Class deleted")
            }
                }
                 .navigationBarItems(
                    leading:
                        HStack(spacing: geometry.size.width / 4.2) {
                            Button(action: {
                                               let classnames = ["german", "math", "english", "music", "history"]
                                
                                
                                                for classname in classnames {
                                                    let newClass = Classcool(context: self.managedObjectContext)
                                                    newClass.attentionspan = Int64.random(in: 0 ... 10)
                                                    newClass.tolerance = Int64.random(in: 0 ... 10)
                                                    newClass.name = classname
                                                    do {
                                                       try self.managedObjectContext.save()
                                                       print("Class made")
                                                      } catch {
                                                       print(error.localizedDescription)
                                                       }
                                                }})
                                {
                                Image(systemName: "gear").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }.padding(.leading, 2.0);
                        
                            Image("Tracr").resizable().scaledToFit().frame(width: geometry.size.width / 4);

                            Button(action: {print("add button clicked")}) {
                                Image(systemName: "plus.app.fill").renderingMode(.original).resizable().scaledToFit().font( Font.title.weight(.medium)).frame(width: geometry.size.width / 12)
                            }
                        }.padding(.top, -11.0)).navigationBarTitle(Text("Classes"), displayMode: .large)
                    
             }
        }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return ClassesView().environment(\.managedObjectContext, context)

    }
}
