//
//  ViewController.swift
//  SpotifyTV
//
//  Created by Andrew Robinson on 6/3/18.
//  Copyright © 2018 xYello, Inc. All rights reserved.
//

import UIKit
import Voucher
import Spartan

class ViewController: UIViewController {

    let voucherClient = VoucherClient(uniqueSharedId: "asdfkqwerpoiuqwer")
    let sPlayer = SPTAudioStreamingController.sharedInstance()

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
        let token = String(data: data, encoding: .utf8)!
        let message = token + " - " + name
        let alert = UIAlertController(title: "Retrieved data", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        voucherClient.stop()

        print(message)
        Spartan.authorizationToken = token
        sPlayer?.delegate = self
        sPlayer?.login(withAccessToken: token)

        Spartan.getMe(success: { user in

            Spartan.getMyPlaylists(limit: 20, offset: 0, success: { (pagingObject) in

                Spartan.getPlaylistTracks(userId: user.uri, playlistId: pagingObject.items[0].id as! String, limit: 20, offset: 0, fields: [], market: .us, success: { (pagingObject) in

                    self.sPlayer?.playSpotifyURI(pagingObject.items[0].track.uri, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                }, failure: { (error) in
                    print(error)
                })
            }, failure: { (error) in
                print(error)
            })

        }, failure: { (error) in
            print(error)
        })
    }

}

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print(audioStreaming)
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error.localizedDescription)
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print(message)
    }

}

