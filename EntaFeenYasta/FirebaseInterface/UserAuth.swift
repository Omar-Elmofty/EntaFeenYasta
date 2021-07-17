//
//  UserAuth.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-04.
//
	
import Foundation
import FirebaseAuth

func authenticateUser(verification_code: String, completion: @escaping (Bool) -> Void)
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
                completion(false)
                return
            }
            completion(true)
            print("USER SUCCESSFULLY SIGNED IN")
        }
    }
    else
    {
        completion(false)
        print("ERROR, DID NOT FIND VERIFICATION ID")
    }
}

func verifyPhoneNumber(phone_number: String, completion: @escaping (Bool) -> Void)
{
    PhoneAuthProvider.provider()
      .verifyPhoneNumber(phone_number, uiDelegate: nil) { verificationID, error in
          if let error = error {
            print("Error during phone number verification \(error.localizedDescription)")
            completion(false)
            return
          }
          // Sign in using the verificationID and the code sent to the user
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
          completion(true)
      }
}

