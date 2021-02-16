#if GALLERY_USE_LOCATION
import CoreLocation
#endif

protocol LocationProviding {
	#if GALLERY_USE_LOCATION
	var location: CLLocation { get }
	#endif
}

struct LocationProvider: LocationProviding {
	#if GALLERY_USE_LOCATION
	let location: CLLocation
	#endif
}
