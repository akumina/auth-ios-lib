//
//  ViewController.swift
//  AkuminaLib
//
//  Created by anbu77raj@gmail.com on 03/13/2023.
//  Copyright (c) 2023 anbu77raj@gmail.com. All rights reserved.
//

import UIKit
import AkuminaLib

class ViewController: UIViewController {

    let akuminaLib : AkuminaLib = AkuminaLib.instance;
    
    @IBOutlet weak var contineButton: UIButton!
    
    @IBAction func contineAction(_ sender: Any) {
        do {
            let clientDetails: ClientDetails = try ClientDetails(authority: "https://login.microsoftonline.com/15d05f6e-046b-4ed5-9ab8-4b6c25f719b5", clientId: "b86cf6b1-745b-47ce-a3c1-912f7ee3d8ac", redirectUri: "msauth.com.mobile.akumina.test://auth", scopes: ["https://graph.microsoft.com/.default"], sharePointScope: "https://akuminadev.sharepoint.com/.default", appManagerURL: "https://mainapp.akumina.dev/api/v2.0/token/preauth", tenantId: "15d05f6e-046b-4ed5-9ab8-4b6c25f719b5")
            try akuminaLib.authenticateWithMSAL(parentViewController: self, clientDetails: clientDetails, enableRollbar: false) { result in
                guard result.error == nil else {
                    print("Error while Auth \(String(describing: result.error))")
                    return
                }
                guard result.token != "" else {
                    print("Token Not found")
                    return
                }
                print(result.token)
            }
//            let acc: AppAccount = AppSettings.getAccount();
//            print("App Tokenn " + (acc.accessToken ?? "Empty" ))
        }catch {
            print(error)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

