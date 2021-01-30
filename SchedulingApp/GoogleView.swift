import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import UIKit
import SwiftUI
import GoogleAPIClientForREST



class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }

        // If the previous `error` is null, then the sign-in was succesful
        print("Successful sign-in!")
        signedIn = true
        
    }
    
    @Published var signedIn: Bool = false
}

struct DetailGoogleView: View
{
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    var classlist: FetchedResults<Classcool>

    @State var classid: String
    @State var googleclassname: String
    @State var classselection: Int = 0
    
    func getlinked() -> Bool
    {
        for classity in classlist
        {
            if (classity.googleclassroomid == classid)
            {
                return true
            }
        }
        return false
    }
    func getunlinkedclasses() -> [String]
    {
        var classities: [String] = []
        for classity in classlist
        {
            if (classity.googleclassroomid == "")
            {
                classities.append(classity.name)
            }
        }
        return classities
    }
    var body: some View
    {
        VStack
        {
            Text(googleclassname)
            Text(classid)
            if (getlinked())
            {
                Text("Succesfully linked")
            }
            else if (self.getunlinkedclasses().count > 0)
            {
                Picker(selection: $classselection, label: Text("Link Class")) {
                    ForEach(0 ..< getunlinkedclasses().count) {
                        if ($0 < self.getunlinkedclasses().count)
                        {
                            Text(self.getunlinkedclasses()[$0])
                        }
                    }

                }
                
                Button(action:{
                    if (self.getunlinkedclasses().count > 0)
                    {
                        for classity in classlist
                        {
                            if (classity.name == self.getunlinkedclasses()[classselection])
                            {
                                classity.googleclassroomid = self.classid
                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                break
                            }
                        }
                    }
                    
                })
                {
                    Text("Link Class")
                }
                
            }
            else
            {
                Text("Add more classes to link your classes on Tracr to Google Classroom")
            }
        }
    }
}


struct GoogleView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Classcool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Classcool.name, ascending: true)])
    
    var classlist: FetchedResults<Classcool>
    @State var classeslist: [String] = []
    @State var classesselected: [Bool] = []
    @State var classesidlist: [String] = []
    @State var assignmentsforclass = [String: [String]]()
    @State private var refreshID = UUID()
    @State private var selection: Set<String> = []
    @State var selectedClass: Int? = 100000

    
    init()
    {
        let defaults = UserDefaults.standard
      //  print(defaults.object(forKey: "accessedclassroom") ?? false)
        let valstuffity = defaults.object(forKey: "accessedclassroom") as! Bool
        if (valstuffity)
        {
            let defaults = UserDefaults.standard
            print("yay")
            print(defaults.object(forKey: "savedgoogleclasses") as! [String])
            classeslist = defaults.object(forKey: "savedgoogleclasses") as! [String]
            classesidlist = defaults.object(forKey: "savedgoogleclassesids") as! [String]
        }
        
    }
    private func selectDeselect(_ singularassignment: String) {
        if selection.contains(singularassignment) {
            selection.remove(singularassignment)
        } else {
            selection.insert(singularassignment)
        }
    }
 
    
    func getassignments(index: Int, id: String, service: GTLRClassroomService) -> Void {
        let idiii = id
        let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii)

        assignmentsquery.pageSize = 1000

        service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
            let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse
            
            if assignmentsforid.courseWork != nil {
                for assignment in assignmentsforid.courseWork! {
                    print(assignment.title!)
                }
            }
        })
    }
    
    func getclasses(service: GTLRClassroomService) -> [(String, String)] {
        let coursesquery = GTLRClassroomQuery_CoursesList.query()

        coursesquery.pageSize = 1000
        var partiallist: [(String, String)] = []
        service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
            let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse

            for course in stuff1.courses! {
                if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                    partiallist.append((course.identifier!, course.name!))
                    print(course.name!)
                }
            }
            
        })
        
        return partiallist
    }
    func getiterationcounter() -> Int
    {
        if (classeslist.count % 2 == 0)
        {
            return classeslist.count/2
        }
        else
        {
            return (classeslist.count+1)/2
        }
    }
    func checklinkedclass(classval: Int) -> Bool
    {
        for classity in classlist
        {
            if (classity.googleclassroomid == classesidlist[classval])
            {
                return true
            }
        }
        return false
    }
    func GetColorFromRGBCode(rgbcode: String, number: Int = 1) -> Color {
        if number == 1 {
            return Color(.sRGB, red: Double(rgbcode[9..<14])!, green: Double(rgbcode[15..<20])!, blue: Double(rgbcode[21..<26])!, opacity: 1)
        }
        
        return Color(.sRGB, red: Double(rgbcode[36..<41])!, green: Double(rgbcode[42..<47])!, blue: Double(rgbcode[48..<53])!, opacity: 1)
    }
    func getclasscolor(classval: Int) -> Color
    {
        if (!checklinkedclass(classval: classval))
        {
            return Color.gray
        }
        for classity in classlist
        {
            if (classity.googleclassroomid == classesidlist[classval])
            {
                return classity.color.contains("rgbcode") ? GetColorFromRGBCode(rgbcode: classity.color) : Color(classity.color)
            }
        }
        
        return (Color("one"))
    }
    var body: some View {
        VStack {
            if googleDelegate.signedIn {
                ScrollView {
   
                    Text(GIDSignIn.sharedInstance().currentUser!.profile.name).font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
                        Text(GIDSignIn.sharedInstance().currentUser!.profile.email).font(.title).fontWeight(.bold).frame(width: UIScreen.main.bounds.size.width-40, alignment: .leading)
       
         
                            
            
                    Button(action: {
                        GIDSignIn.sharedInstance().signOut()
                        googleDelegate.signedIn = false
                    }) {
                        Text("Sign Out")
                    }

                    Spacer()
                    Divider()
                    ForEach(0..<classeslist.count, id: \.self)
                    {
                        classityval in
                        NavigationLink(destination: DetailGoogleView(classid: classesidlist[classityval], googleclassname: classeslist[classityval]), tag: classityval, selection: self.$selectedClass) {
                            EmptyView()
                        }

                    }//.id(refreshID)

                    ForEach(0..<getiterationcounter(), id: \.self) { classityval in
                        HStack {
                            Button(action:{
                                print("hello")
                                self.selectedClass = 2*classityval
                                print(self.selectedClass!)
                            }) {
                                ZStack {
                                   // RoundedRectangle(cornerRadius: 10, style: .continuous).fill(self.checklinkedclass(classval: 2*classityval) ? Color.blue : Color.gray).frame(width: (UIScreen.main.bounds.size.width-30)/2, height: 100)
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(self.getclasscolor(classval: 2*classityval))
                                    Text(classeslist[2*classityval]).frame(width: (UIScreen.main.bounds.size.width-70)/2, height: 80).padding(10)
                                }.shadow(radius: 10)
                                
                            }.buttonStyle(PlainButtonStyle())
                            //need to add check if odd number of google classes without type-check error
                            Spacer()
                    
                                Button(action:{
                                    print("hello")
                                    self.selectedClass = 2*classityval+1
                                    print(self.selectedClass!)

                                })
                                {
                                    ZStack
                                    {
                                        let n = 2*classityval+1
                                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(self.getclasscolor(classval: 2*classityval+1))
                                        Text(classeslist[n < classeslist.count ? n : 0]).frame(width: (UIScreen.main.bounds.size.width-70)/2, height: 80).padding(10)
                                    }.shadow(radius: 10)//.opacity(2*classityval+1 < classeslist.count ? 1 : 0)

                                }.buttonStyle(PlainButtonStyle())
                        }
                }.padding(.horizontal, 10)//.id(refreshID)
                
//                    NavigationLink(destination: GoogleAssignmentsView())
//                    {
//                        Text("See Assignments???")
//                    }
                }.frame(width: UIScreen.main.bounds.size.width)
            } else {
                VStack
                {
                    Spacer()
                    Button(action: {
                        GIDSignIn.sharedInstance().signIn()
                    }) {
                        
                        ZStack
                        {
                            RoundedRectangle(cornerRadius: 10, style: .circular).fill(Color.gray).frame(width: UIScreen.main.bounds.size.width-100, height: 50)
                            Text("Sign in to Google")
                        }.shadow(radius: 20)
                    }
                    Spacer()
                }
            }
        }.frame(width: UIScreen.main.bounds.size.width)
        .onAppear
        {
          //  print("success")
            let defaults = UserDefaults.standard
          //  print(defaults.object(forKey: "accessedclassroom") ?? false)
            let valstuffity = defaults.object(forKey: "accessedclassroom") as! Bool
            //let bobbity = defaults.object(forKey: "lastaccessdate")
            if (!valstuffity)
            {
                GIDSignIn.sharedInstance().restorePreviousSignIn()

                defaults.set(true, forKey: "accessedclassroom")
                print("fetching stuff")
                var partiallist: [(String, String)] = []
                
                let service = GTLRClassroomService()
                service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                
                let coursesquery = GTLRClassroomQuery_CoursesList.query()

                coursesquery.pageSize = 1000
                service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
                    let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse

                    for course in stuff1.courses! {
                        if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                            partiallist.append((course.identifier!, course.name!))
                            print(course.name!)
                        }
                    }
                    
                })
                
//                partiallist = getclasses(service: service)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
                    print("ASDFASDFASDJFPIASJFIASPDFJASPFJASDPFJADFAPJADSPFJDSA:FJADSFJDS:FAD")
                    print(partiallist.count)
                    for val in partiallist
                    {
                        classeslist.append(val.1)
                    }
                    
                    classeslist = Array(Set(classeslist))
                    classeslist.sort()
                    for val in classeslist
                    {
                        for pairity in partiallist
                        {
                            if (pairity.1 == val)
                            {
                                classesidlist.append(pairity.0)
                            }
                        }
                    }
//                    for _ in classeslist
//                    {
//                        classesselected.append(false)
//                    }
                    
//                    let arraykewl = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
//                    for (index, classval) in classeslist.enumerated()
//                    {
//                        if (arraykewl.contains(classval))
//                        {
//                            classesselected[index] = true
//                        }
//                    }
                    
                    
                    self.refreshID = UUID()
                    
                    
                }

//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3000)) {
//
//                    for (_, idiii) in partiallist.enumerated() {
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
//                            let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii.0)
//                            let workingdate = Date(timeIntervalSinceNow: -3600*24*7)
//                            let dayformatter = DateFormatter()
//                            let monthformatter = DateFormatter()
//                            let yearformatter = DateFormatter()
//                            yearformatter.dateFormat = "yyyy"
//                            monthformatter.dateFormat = "MM"
//                            dayformatter.dateFormat = "dd"
//                            assignmentsquery.pageSize = 1000
//                            var vallist: [String] = []
//                            service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
//                                let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse
//
//                                if assignmentsforid.courseWork != nil {
//                                    for assignment in assignmentsforid.courseWork! {
//                                        print(assignment.title!)
//                                        if (assignment.dueDate != nil)
//                                        {
//                                        if (assignment.dueDate!.day! as! Int >= Int(dayformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.month as! Int >= Int(monthformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.year as! Int >= Int(yearformatter.string(from: workingdate)) ?? 0 )
//                                        {
//                                            vallist.append(assignment.title!)
//                                        }
//                                        }
//                                    }
//                                }
//                                assignmentsforclass[idiii.1] = vallist
//                                self.refreshID = UUID()
//                            })
//
//                        }
//                    }
//                }
            }
            else
            {
                let defaults = UserDefaults.standard
                print("yay")
                classeslist = defaults.object(forKey: "savedgoogleclasses") as! [String]
                classesidlist = defaults.object(forKey: "savedgoogleclassesids") as! [String]
                
               // self.refreshID = UUID()

            }
        
        }.onDisappear
        {
            let defaults = UserDefaults.standard

            defaults.set(classeslist, forKey: "savedgoogleclasses")
            defaults.set(classesidlist, forKey: "savedgoogleclassesids")

        }
    }
}
struct GoogleAssignmentsView: View
{   @State var classeslist: [String] = []
    @State var refreshID = UUID()
    @State var assignmentsforclass = [String:[String]]()
    var body: some View
    {
        VStack
        {

                ForEach(classeslist,id: \.self)
                {
                    classity in
                    Text(classity).fontWeight(.bold)
                    ForEach(assignmentsforclass[classity] ?? [], id: \.self)
                    {
                        assignmenty in
                        Text(assignmenty)
                    }.id(refreshID)
                    
                }.id(refreshID)

            
        }.onAppear
        {
            let defaults = UserDefaults.standard
            let googleclasses = defaults.object(forKey: "savedgoogleclasses") as? [String] ?? []
            classeslist = googleclasses
            let googleclassesids = defaults.object(forKey: "savedgoogleclassesids") as? [String] ?? []
            
            let service = GTLRClassroomService()
            service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
            for (index, idiii) in googleclassesids.enumerated() {
                let assignmentsquery = GTLRClassroomQuery_CoursesCourseWorkList.query(withCourseId: idiii)
                let workingdate = Date(timeIntervalSinceNow: -3600*24*7)
                let dayformatter = DateFormatter()
                let monthformatter = DateFormatter()
                let yearformatter = DateFormatter()
                yearformatter.dateFormat = "yyyy"
                monthformatter.dateFormat = "MM"
                dayformatter.dateFormat = "dd"
                assignmentsquery.pageSize = 1000
                var vallist: [String] = []
                service.executeQuery(assignmentsquery, completionHandler: {(ticket, stuff, error) in
                    let assignmentsforid = stuff as! GTLRClassroom_ListCourseWorkResponse

                    if assignmentsforid.courseWork != nil {
                        for assignment in assignmentsforid.courseWork! {
                            //print(assignment.title!)
                            if (assignment.dueDate != nil)
                            {
                                if (assignment.dueDate!.day! as! Int >= Int(dayformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.month as! Int >= Int(monthformatter.string(from: workingdate)) ?? 0 && assignment.dueDate!.year as! Int >= Int(yearformatter.string(from: workingdate)) ?? 0 )
                                {
                                 //   print(assignment.title!)
//                                    var newComponents = DateComponents()
//                                    newComponents.timeZone = .current
//                                    newComponents.day = Int(assignment.dueDate!.day!)
//                                    newComponents.month = Int(assignment.dueDate!.month!)
//                                    newComponents.year = Int(assignment.dueDate!.year!)
//                                    newComponents.hour = assignment.dueTime!.hours as! Int
//                                    newComponents.minute = assignment.dueTime!.minutes as! Int
//                                    newComponents.second = 0
                              //      newComponents.second = assignment.dueTime!.seconds as! Int
                                    vallist.append(assignment.title!)
                                }
                            }
                        }
                    }
                    assignmentsforclass[classeslist[index]] = vallist
                    print(vallist)
                    self.refreshID = UUID()
                })

                
            }
                
        }
    }
}
//struct SignInButton: UIViewRepresentable {
//    func makeUIView(context: Context) -> GIDSignInButton {
//        let button = GIDSignInButton()
//        // Customize button here
//        button.colorScheme = .light
//        return button
//    }
//    func updateUIView(_ uiView: UIViewType, context: Context) {}
//}
