#if GALLERY_USE_LOCATION
import Foundation
import CoreLocation

class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  var latestLocationProvider: LocationProviding?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
  }

  func start() {
    locationManager.startUpdatingLocation()
  }

  func stop() {
    locationManager.stopUpdatingLocation()
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Pick the location with best (= smallest value) horizontal accuracy
	if let location = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first {
		latestLocationProvider = LocationProvider(location: location)
	}
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    } else {
      locationManager.stopUpdatingLocation()
    }
  }
}

#endif
