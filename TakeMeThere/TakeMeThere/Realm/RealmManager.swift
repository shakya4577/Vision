import UIKit
import RealmSwift
import Realm

class RealmManager: NSObject
{
    static let realmDelegate:Realm =  try! Realm()
    static func saveUserDetail(userDetails:UserDetailModel)
    {
      try!  realmDelegate.write
         {
            ()-> Void in
            realmDelegate.add(userDetails)
         }
    }
    
    static func getUserDetail()->UserDetailModel
    {
        let userModel = realmDelegate.objects(UserDetailModel.self)
        return userModel.first!
    }
    
    static func saveLocation(locationDetails:LocationModel)
    {
        try!  realmDelegate.write
        {
            ()-> Void in
            realmDelegate.add(locationDetails)
        }
    }
    
    static func getUserDetail()->LocationModel
    {
        let locationModel = realmDelegate.objects(LocationModel.self)
        return locationModel.first!
    }
}