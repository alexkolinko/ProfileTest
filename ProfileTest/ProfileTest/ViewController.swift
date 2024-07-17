//
//  ViewController.swift
//  ProfileTest
//
//  Created by kolinko oleksandr on 16.07.2024.
//

import UIKit

class ViewController: UIViewController {

    // - Outlets
    @IBOutlet weak var showProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showProfileButton.setTitle("User profile", for: .normal)
        showProfileButton.setTitleColor(.white, for: .normal)
        showProfileButton.backgroundColor = .black
    }

    @IBAction func showProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProfileViewController", bundle: nil)
        guard
            let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        else { return }
        navigationController?.pushViewController(controller, animated: true)
        
    }
}
