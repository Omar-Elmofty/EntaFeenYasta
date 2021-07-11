//
//  UserAuth.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-04.
//
	
import Foundation
import FirebaseAuth

func authenticateUser(verification_code: String)
{
    if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    {
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verification_code
        )
        Auth.auth().signIn(with: credential) { auth_result, error in
            if let error = error {
                print("Error occured during sign in \(error.localizedDescription)")
                return
            }
            print("USER SUCCESSFULLY SIGNED IN")
        }
    }
    else
    {
        print("ERROR, DID NOT FIND VERIFICATION ID")
    }
}

func verifyPhoneNumber(phone_number: String)
{
    PhoneAuthProvider.provider()
      .verifyPhoneNumber(phone_number, uiDelegate: nil) { verificationID, error in
          if let error = error {
            print("Error during phone number verification \(error.localizedDescription)")
            return
          }
          // Sign in using the verificationID and the code sent to the user
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
      }
}

