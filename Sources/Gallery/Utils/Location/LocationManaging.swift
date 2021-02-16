protocol LocationManaging {

	func start()
	func stop()
	var latestLocationProvider: LocationProviding? { get }
}
