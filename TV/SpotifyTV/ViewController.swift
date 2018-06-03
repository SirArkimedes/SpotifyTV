//
//  ViewController.swift
//  SpotifyTV
//
//  Created by Andrew Robinson on 6/3/18.
//  Copyright © 2018 xYello, Inc. All rights reserved.
//

import UIKit
import Voucher

class ViewController: UIViewController {

    let voucherClient = VoucherClient(uniqueSharedId: "asdfkqwerpoiuqwer")

    override func viewDidLoad() {
        super.viewDidLoad()

        voucherClient.startSearching { authData, displayName, error in
            if let data = authData, let name = displayName {
                self.recieved(data: data, from: name)
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private func recieved(data: Data, from name: String) {
        print(String(data: data, encoding: .utf8)! + " - " + name)
        voucherClient.stop()
    }

}

