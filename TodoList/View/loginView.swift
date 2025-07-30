//章珍卓 - Vesha Halvin Winrich Chandra - L20242005

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var rememberMe: Bool = false
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isPhoneLoginError: Bool = false
    @State private var isPhoneLoginSheetPresented: Bool = false
    @State private var verificationID: String?
    @State private var isVerificationCodeStep = false
    @State private var verificationCode: String = ""
    @State private var isSignUpSheetPresented = false
    @State private var isSignUpPresented = false


    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 10)
                
                VStack(spacing: 8) {
                    Text("Get Started now")
                        .font(.system(size: 24, weight: .bold))
                        .overlay(
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                                .mask(
                                    Text("Get Started now")
                                        .font(.system(size: 24, weight: .bold))
                                )
                        )
                    
                    Text("Create an account or log in to explore our app")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
                
                VStack(spacing: 12) {
                    GoogleSignInButton()
                    
                    Button(action: {
                        isPhoneLoginSheetPresented = true
                    }) {
                        HStack {
                            Image(systemName: "phone")
                            Text("Sign in with Phone")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("Or")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)

                Button("Don't have an account? Sign up") {
                    isSignUpPresented = true
                }
                .font(.caption)
                .foregroundColor(.blue)

                Button(action: {
                    authViewModel.signInWithEmail(email: email, password: password) { error in
                        if let error = error as NSError? {
                                if error.code == AuthErrorCode.userNotFound.rawValue {
                                    DispatchQueue.main.async {
                                        isSignUpPresented = true
                                    }
                                } else {
                                    print("Email login failed: \(error.localizedDescription)")
                                }
                            } else {
                                print("User signed in with email: \(email)")
                            }
                    }
                }) {
                    Text("Log In")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .sheet(isPresented: $isSignUpPresented) {
            SignUpPopup(email: $email, password: $password, isPresented: $isSignUpPresented)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isPhoneLoginSheetPresented) {
            PhoneLoginPopup(
                phoneNumber: $phoneNumber,
                verificationCode: $verificationCode,
                isVerificationCodeStep: $isVerificationCodeStep,
                isPhoneLoginError: $isPhoneLoginError,
                onSendCode: {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { id, error in
                        if let error = error {
                            print("Error sending code: \(error.localizedDescription)")
                            isPhoneLoginError = true
                        } else {
                            verificationID = id
                            isVerificationCodeStep = true
                        }
                    }
                },
                onVerifyCode: {
                    guard let id = verificationID else { return }
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: verificationCode)
                    Auth.auth().signIn(with: credential) { result, error in
                        if let error = error {
                            print("Phone sign-in failed: \(error.localizedDescription)")
                            isPhoneLoginError = true
                        } else {
                            print("User signed in: \(result?.user.uid ?? "unknown")")
                            authViewModel.isSignedIn = true
                            authViewModel.currentUserUID = result?.user.uid
                            isPhoneLoginSheetPresented = false
                        }
                    }
                }
            ).presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

struct PhoneLoginPopup: View {
    @Binding var phoneNumber: String
    @Binding var verificationCode: String
    @Binding var isVerificationCodeStep: Bool
    @Binding var isPhoneLoginError: Bool
    var onSendCode: () -> Void
    var onVerifyCode: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {

            Text(isVerificationCodeStep ? "Enter Code" : "Phone Login")
                .font(.title2.bold())
                .padding(.top, 8)

            if isVerificationCodeStep {
                TextField("6-digit code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                TextField("Phone number (e.g. +628...)", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            if isPhoneLoginError {
                Text("Something went wrong.")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: isVerificationCodeStep ? onVerifyCode : onSendCode) {
                Text(isVerificationCodeStep ? "Verify" : "Send Code")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button("Cancel") {
                phoneNumber = ""
                verificationCode = ""
                isVerificationCodeStep = false
                isPhoneLoginError = false
            }
            .foregroundColor(.red)
            .padding(.bottom, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }
}

struct SignUpPopup: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isPresented: Bool
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {

            Text("Sign Up")
                .font(.title2.bold())
                .padding(.top, 8)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Create Account") {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error as NSError? {
                        errorMessage = error.code == AuthErrorCode.emailAlreadyInUse.rawValue
                            ? "Email already in use. Try logging in."
                            : error.localizedDescription
                    } else {
                        print("User created: \(result?.user.email ?? "")")
                        isPresented = false
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(.red)
            .padding(.bottom, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                configuration.label
            }
        }
    }
}

struct GoogleSignInButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                authViewModel.signInWithGoogle(presenting: rootVC)
            }
        }) {
            HStack {
                Image(systemName: "globe")
                Text("Sign in with Google")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
