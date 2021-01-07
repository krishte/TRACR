import GoogleSignIn
import UIKit
import SwiftUI



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

struct GoogleView: View
{
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View
    {
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
