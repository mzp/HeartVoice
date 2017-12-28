//
//  ViewController.swift
//  HeartVoice
//
//  Created by mzp on 2017/12/27.
//  Copyright © 2017 mzp. All rights reserved.
//

import UIKit
import HealthKit
import NorthLayout

class ViewController: UITableViewController {
    private let browser = HeartVoiceServiceBrowser(name: UIDevice.current.name)

    init() {
        super.init(style: .grouped)
        title = "HeartVoice"
        browser.onStateChange = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        browser.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        browser.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browser.sessions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let session = browser.sessions[indexPath.row]
        cell.textLabel?.text = session.server?.displayNameWithoutPrefix ?? "Connecting to server..."
        cell.accessoryType = .detailDisclosureButton
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let session = browser.sessions[indexPath.row]
        guard let server = session.server else {
            return
        }
        let vc = ClientViewController(client: HeartVoiceServiceClient(session: session, server: server))
        navigationController?.pushViewController(vc, animated: true)
    }
}
