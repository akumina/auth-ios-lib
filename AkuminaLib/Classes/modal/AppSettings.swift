//
//  AppSettings.swift
//  akuminaDev
//
//  Created by Mac on 17/02/23.
//

import Foundation


public class AppSettings {
    
    public static func saveAccount(account: AppAccount ){
        do {
            let data = try JSONEncoder().encode(account)
            UserDefaults.standard.set(data, forKey: "appAccount")
        } catch let error {
            print("Error encoding: \(error)");
        }
    }
    
    public static func getAccount()  -> AppAccount {
        do {
            let data =  UserDefaults.standard.data(forKey: "appAccount");
            
            if(data != nil) {
                let app: AppAccount =  try JSONDecoder().decode(AppAccount.self, from: data!);
                return app;
            }
            return AppAccount();
        }catch {
            print("Error loading Account \(error)");
            return AppAccount();
        }
    }
    
    public static func updateToken (token: String) {
       
            var appAccount = AppSettings.getAccount();
            appAccount.pushToken = token;
            AppSettings.saveAccount(account: appAccount);
       
    }
}
