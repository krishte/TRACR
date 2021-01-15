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

struct GoogleView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    var body: some View {
        Group {
            if googleDelegate.signedIn {
                VStack {
                    Text(GIDSignIn.sharedInstance().currentUser!.profile.name)
                    Text(GIDSignIn.sharedInstance().currentUser!.profile.email)
                    Button(action: {
                        GIDSignIn.sharedInstance().signOut()
                        googleDelegate.signedIn = false
                    }) {
                        Text("Sign Out")
                    }
                    Button(action: {
                        var ids: [String] = []
                        var classnames: [String] = []
                        
                        let service = GTLRClassroomService()
                        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
                        
                        func getassignments(index: Int, id: String) -> Void {
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
                        
                        func getclasses() -> Void {
                            let coursesquery = GTLRClassroomQuery_CoursesList.query()

                            coursesquery.pageSize = 1000

                            service.executeQuery(coursesquery, completionHandler: {(ticket, stuff, error) in
                                let stuff1 = stuff as! GTLRClassroom_ListCoursesResponse

                                for course in stuff1.courses! {
                                    if course.courseState == kGTLRClassroom_Course_CourseState_Active {
                                        classnames.append(course.name!)
                                        ids.append(course.identifier!)
                                        print(course.name!)
                                    }
                                }
                            })
                        }
                        
                        getclasses()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
                            print(ids.count)

                            for (index, idiii) in ids.enumerated() {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2000)) {
                                    getassignments(index: index, id: idiii)
                                }
                            }
                        }
                    }) {
                        Text("do stuff")
                    }
                }
            } else {
                Button(action: {
                    GIDSignIn.sharedInstance().signIn()
                }) {
                    Text("Sign In")
                }
            }
        }.onAppear
        {
            GIDSignIn.sharedInstance().restorePreviousSignIn()

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
