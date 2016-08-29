//
//  NewHomeViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class NewHomeViewController: UIViewController {

    @IBOutlet var homeView : HomeStackView!
    
    let dataSource = HomeDataSource()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.active = true
        
        dataSource.stateMachine.subject.asDriver(onErrorJustReturn: .Error).driveNext{ [weak self] (state) in
            self?.applyData()
        }.addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataSource.active = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func applyData() {
        homeView.activateViewsForTab(self.dataSource.currentTab)
    }
    
}
