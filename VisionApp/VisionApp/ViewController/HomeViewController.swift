import UIKit
import Speech
import MapKit
class HomeViewController: UIViewController,SFSpeechRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,PrimeDelegate
{
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var mainView: UIImageView!
    
    private var localLocationList = [LocationModel]()
    private var isWalkMode = true
    internal var isSelection = false
    internal var locationSelectionCounter = 0
    @IBOutlet weak var txtLocationSearch: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTableView.delegate = self
        locationTableView.dataSource = self
        AppDelegate.primeDelegate = self
        AppDelegate.locationManager.appleMap = mapView
        txtLocationSearch.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
       localLocationList = RealmManager.getLocationList()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
        resignFirstResponder()
    }
   
    func whereAmI()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            AppDelegate.locationManager.getUserLocatoin { (location: String) in
                AppDelegate.speechManager.voiceOutput(message:"You are at " + location)
            }
        })
    }
    
    @objc func textFieldDidChange(textField: UITextField)
    {
        let searchText = textField.text!
        localLocationList = RealmManager.getLocationList()
        if(searchText != "")
        {
            localLocationList = localLocationList.filter { $0.locationName.contains(searchText) }
            if(localLocationList.count==0)
            {
                AppDelegate.locationManager.searchLocationList(locationInput: textField.text!) {
                    (returnedlocationList:[LocationModel])
                    in
                    self.localLocationList = returnedlocationList
                    self.locationTableView.reloadData()
                }
            }
        }
        else
        {
            localLocationList = RealmManager.getLocationList()
        }
        locationTableView.reloadData()
    }
    
    func filterLocationList(filterInput: String)
    {
        isSelection = true
        if (filterInput == "")
        {
            selectDestination()
            return
        }
        else
        {
             localLocationList = localLocationList.filter { $0.locationName.contains(filterInput) }
            if(localLocationList.count==0)
            {
                AppDelegate.locationManager.searchLocationList(locationInput: filterInput) {
                    (returnedlocationList:[LocationModel])
                    in
                    self.localLocationList = returnedlocationList
                    self.locationTableView.reloadData()
                    self.selectDestination()
                }
            }
            else
            {
                locationTableView.reloadData()
                selectDestination()
            }
        }
       
    }
    
    func selectDestination()
    {
        if(locationSelectionCounter<0 || locationSelectionCounter>localLocationList.count-1)
        {
            AppDelegate.speechManager.voiceOutput(message: "No more location available")
            locationSelectionCounter=0
            return
        }
        AppDelegate.speechManager.voiceOutput(message: localLocationList[locationSelectionCounter].locationName)
     }
    
    func letsWalk() {
        isWalkMode = true
        performSegue(withIdentifier: "VisionSegue", sender: Data())
    }
    
    func takeMetoDestination()
    {
        isWalkMode = false
        performSegue(withIdentifier: "VisionSegue", sender: Data())
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VisionViewController
        {
            let visionViewController = segue.destination as? VisionViewController
            visionViewController?.isWalk = isWalkMode
            if(!isWalkMode)
            {
                visionViewController?.destinationLocation = localLocationList[locationSelectionCounter]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localLocationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LocationTableCell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath) as! LocationTableCell
        cell.initCell(locName: localLocationList[indexPath.row].locationName)
        return cell
    }
    
}





//
func testRealm()
{
    let loc1:LocationModel = LocationModel()
    loc1.locationName = "Loc1"
    loc1.locatoinLatitude = 30.484872
    loc1.locationLongitude = 49.0092393
    RealmManager.saveLocation(locationDetails: loc1)
    
    let loc2:LocationModel = LocationModel()
    loc2.locationName = "Loc2"
    loc2.locatoinLatitude = 70.484872
    loc2.locationLongitude = 59.0092393
    RealmManager.saveLocation(locationDetails: loc2)
    
    let loc3:LocationModel = LocationModel()
    loc3.locationName = "Loc2"
    loc3.locatoinLatitude = 40.484872
    loc3.locationLongitude = 69.0092393
    RealmManager.saveLocation(locationDetails: loc3)
    
    let loc4:LocationModel = LocationModel()
    loc4.locationName = "Loc3"
    loc4.locatoinLatitude = 10.484872
    loc4.locationLongitude = 39.0092393
    RealmManager.saveLocation(locationDetails: loc4)
}