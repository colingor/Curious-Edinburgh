
//  CuriousEdinburghAPI.swift
//  Curious Edinburgh
//
//  Created by Colin Gormley on 13/04/2016.
//  Copyright © 2016 Edina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import DATAStack
import Sync

class _CuriousEdinburghAPI {
    
    var dataStack: DATAStack?
    
    init() {
  
    }
    
    func syncBlogPosts(completion: (()) -> Void) {
        // Sync posts from API to Core Data model
        
        Alamofire.request(.GET, Constants.API.url).validate().responseJSON { response in
            switch response.result {
            case .Success(let data):
//                let json = JSON(data).arrayValue
//                print(json)
               
                
                // Persist to Core Data
                self.dataStack?.performInNewBackgroundContext { backgroundContext in
                    Sync.changes(
                        data as! [[String : AnyObject]],
                        inEntityNamed: Constants.Entity.blogPost,
                        predicate: nil,
                        parent: nil,
                        inContext: backgroundContext,
                        dataStack: self.dataStack!,
                        completion: { error in
                            print(error)
                            completion()
                    })
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func fetchBlogPostsFromCoreData()  -> [BlogPost] {
        let request = NSFetchRequest(entityName: Constants.Entity.blogPost)
        var blogPosts = (try! self.dataStack?.mainContext.executeFetchRequest(request)) as! [BlogPost]
        blogPosts.sortInPlace(self.sortBlogPostsByTourNumberAsc)
        return blogPosts
    }
    
    func sortBlogPostsByTourNumberAsc(post1: BlogPost, post2: BlogPost) -> Bool {
        if let number1 = post1.tourNumber, number2 = post2.tourNumber {
            return Int(number1) < Int(number2)
        }
        return false
    }
}

let curiousEdinburghAPI = _CuriousEdinburghAPI()