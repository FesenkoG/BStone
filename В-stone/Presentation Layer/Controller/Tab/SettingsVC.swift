//
//  SettingsVC.swift
//  В-stone
//
//  Created by Георгий Фесенко on 16.02.2018.
//  Copyright © 2018 Georgy. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {
    
    var model: QuizModel!
    var localDataService: LocalDataService! = LocalDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBarItem.selectedImage = UIImage(named: "settings_selected")!.withRenderingMode(.alwaysOriginal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }


    @IBAction func logOutBtnWasPressed(_ sender: Any) {
        let logoutPopout = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do{
                try Auth.auth().signOut()
                self.localDataService.cleanStorage()
                self.performSegue(withIdentifier: "backToStart", sender: nil)
                AppData.shared.isEditScreenExists = false
            } catch {
                print(error)
            }
        }
        logoutPopout.addAction(logoutAction)
        present(logoutPopout, animated: true) {
            logoutPopout.view.superview?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAllert))
            logoutPopout.view.superview?.addGestureRecognizer(tap)
        }
    }
    
    func loadUserData() {
        let resultQuiz = localDataService.fetchQuizData()
        switch resultQuiz {
        case .success(let quiz):
            model = quiz
        case .failure(let error):
            print(error)
        }
        
    }
    
    @objc func dismissAllert() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfileDataWasPressed(_ sender: Any) {
        if AppData.shared.isEditScreenExists {
            self.performSegue(withIdentifier: "editData", sender: nil)
        } else {
            guard let howOldVC = storyboard?.instantiateViewController(withIdentifier: "HowOldAreYouVC") as? HowOldAreYouVC else { return }
            howOldVC.model = model
            self.present(howOldVC, animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBAction func deleteAccountBtnWasPressed(_ sender: Any) {
        let logoutPopout = UIAlertController(title: "Delete account?", message: "Are you sure you want to delete account?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Delete?", style: .destructive) { (buttonTapped) in
            guard let userId = Auth.auth().currentUser?.uid else { return }            
            DataService.instance.deleteUser(withId: userId, completionHandler: { (success) in
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if error == nil {
                        self.localDataService.cleanStorage()
                        self.performSegue(withIdentifier: "backToStart", sender: nil)
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                })
            })
        }
        
        logoutPopout.addAction(logoutAction)
        present(logoutPopout, animated: true) {
            logoutPopout.view.superview?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAllert))
            logoutPopout.view.superview?.addGestureRecognizer(tap)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HowOldAreYouVC {
            vc.model = model
        }
    }
}
