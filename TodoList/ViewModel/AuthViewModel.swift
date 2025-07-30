//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUserUID: String?
    
    @Published private(set) var user: User?
    
    init() {
        if let user = Auth.auth().currentUser {
            self.isSignedIn = true
            self.currentUserUID = user.uid
            self.fetchUserData()
        } else {
            self.isSignedIn = false
            self.currentUserUID = nil
        }
    }

    
    private func fetchUserData() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userUID).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                do {
                    self.user = try document.data(as: User.self)
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("Invalid sign-in result")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.isSignedIn = true
                        self.currentUserUID = authResult?.user.uid
                        self.fetchUserData()
                    }
                }
            }
        }
    }
    
    func signInWithTestPhone(phoneNumber: String, verificationCode: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Failed to get verification ID: \(error.localizedDescription)")
                return
            }
            guard let verificationID = verificationID else { return }
                let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
            )
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Sign-in error: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.currentUserUID = result?.user.uid
                    self.fetchUserData()
                    print("Signed in with UID: \(self.currentUserUID ?? "unknown")")
                }
            }
        }
    }
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    completion(error)
                } else {
                    DispatchQueue.main.async {
                        self.isSignedIn = true
                        self.currentUserUID = result?.user.uid
                        self.fetchUserData()
                    }
                    completion(nil)
                }
            }
        }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()

            self.user = nil
            self.isSignedIn = false
            self.currentUserUID = nil

            if Auth.auth().currentUser == nil {
                print("✅ User signed out successfully.")
            } else {
                print("❌ Sign-out failed. Current user still exists: \(Auth.auth().currentUser?.uid ?? "unknown")")
            }

        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

}
