//
//  ViewController.swift
//  SpotifyTVAuthenticator
//
//  Created by Andrew Robinson on 6/3/18.
//  Copyright © 2018 xYello, Inc. All rights reserved.
//

import UIKit
import SafariServices
import Voucher

class ViewController: UIViewController {

    private var firstLoad = false

    private var safari: SFSafariViewController!

    private var token = ""
    private var server = VoucherServer(uniqueSharedId: "asdfkqwerpoi;uqwer")

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(sessionChanged), name: NSNotification.Name(rawValue: "SpotifySessionUpdated"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let authUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL(), !firstLoad {
            safari = SFSafariViewController(url: authUrl)

            present(safari, animated: true, completion: nil)
            firstLoad = true
        }

        guard let auth = SPTAuth.defaultInstance() else {
            return
        }

        if auth.hasTokenRefreshService {
            auth.renewSession(auth.session) { error, session in
                auth.session = session

                if let error = error {
                    print(error.localizedDescription)
                } else if let session = session {
                    self.openServer(with: session.accessToken)
                }
            }
        }

        if let session = auth.session, session.isValid() {
            openServer(with: session.accessToken)
        }
    }

    private func openServer(with token: String) {
        self.token = token

        server.startAdvertising { displayName, handler in
            let alert = UIAlertController(title: "Found a device!", message: "Allow \(displayName) access to your login?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No!", style: .cancel, handler: { action in
                handler(nil, nil)
            }))

            alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { action in
                handler(self.token.data(using: .utf8)!, nil)
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc private func sessionChanged() {
        guard let _ = SPTAuth.defaultInstance() else {
            return
        }
        safari.dismiss(animated: true, completion: nil)
    }

}

