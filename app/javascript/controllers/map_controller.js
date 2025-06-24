import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet-control-geocoder"

export default class extends Controller {
  static targets = ["latitude", "longitude", "map", "currentLocation", "errorMsg", "errorText"]
  static values = {
    marker_text: String,
    latitude: Number,
    longitude: Number
  }

  connect() {
    this.defaultLocation = { lat: 23.79930876698311, lng: 90.44951877721275 }
    // if the latitude and longitude are set then use those as the default location
    this.map = null
    this.marker = null
    if (this.hasLatitudeTarget && this.hasLongitudeTarget && this.latitudeTarget.value && this.longitudeTarget.value) {
      this.defaultLocation.lat = parseFloat(this.latitudeTarget.value)
      this.defaultLocation.lng = parseFloat(this.longitudeTarget.value)
    }
    if (this.hasMarkerTextValue)
      var markerText = this.markerTextValue
    else
      var markerText = null
    if (this.hasLatitudeValue && this.hasLongitudeValue) {
      this.fixedLocation(markerText)
    } else {
      this.getLocation(markerText)
    }
  }

  getLocation(popMsg = "Selected Location") {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const latitude = parseFloat(position.coords.latitude.toFixed(18))
          const longitude = parseFloat(position.coords.longitude.toFixed(18))

          this.hideError()

          this.latitudeTarget.value = latitude
          this.longitudeTarget.value = longitude

          if (!this.map) {
            this.initializeMap(latitude, longitude, "Current Location")
          } else {
            this.setMapView(latitude, longitude)
          }
        },
        (error) => {
          this.showError(error)
          if (this.hasLatitudeTarget && this.hasLongitudeTarget) {
            this.latitudeTarget.value = this.defaultLocation.lat
            this.longitudeTarget.value = this.defaultLocation.lng
          }

          if (!this.map) {
            this.initializeMap(this.defaultLocation.lat, this.defaultLocation.lng, "Default Location")
          }
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
      )
    } else {
      this.latitudeTarget.value = this.defaultLocation.lat
      this.longitudeTarget.value = this.defaultLocation.lng
      this.initializeMap(this.defaultLocation.lat, this.defaultLocation.lng, "Default Location")
    }
  }

  fixedLocation(popMsg = "Selected Location") {
    const lat = parseFloat(this.latitudeValue || this.defaultLocation.lat)
    const lng = parseFloat(this.longitudeValue || this.defaultLocation.lng)

    if (this.map) return // prevent reinitialization

    this.map = L.map(this.mapTarget, {
      center: [lat, lng],
      zoom: 15,
      dragging: false,
      scrollWheelZoom: false,
      doubleClickZoom: true,
      boxZoom: false,
      touchZoom: 'center',
      keyboard: false,
      zoomControl: true
    })

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap for StudErn"
    }).addTo(this.map)

    this.marker = L.marker([lat, lng], { draggable: false }).addTo(this.map).bindPopup(popMsg).openPopup()
  }

  initializeMap(lat, lng, popMsg = "Selected Location") {
    this.map = L.map(this.mapTarget).setView([lat, lng], 15)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap for StudErn'
    }).addTo(this.map)

    this.marker = L.marker([lat, lng]).addTo(this.map).bindPopup(popMsg).openPopup()

    this.map.on('click', (event) => {
      const { lat, lng } = event.latlng
      this.updateMarker(lat, lng)
    })

    L.Control.geocoder({
      defaultMarkGeocode: false
    }).on('markgeocode', (e) => {
      const { center } = e.geocode
      this.map.setView(center, 15)
      this.updateMarker(center.lat, center.lng)
    }).addTo(this.map)
  }

  setMapView(lat, lng) {
    this.map.setView([lat, lng], 15)
    this.updateMarker(lat, lng)
  }

  updateMarker(lat, lng) {
    if (this.marker) this.map.removeLayer(this.marker)
    this.marker = L.marker([lat, lng]).addTo(this.map)
    this.latitudeTarget.value = lat
    this.longitudeTarget.value = lng
  }

  showError(error) {
    this.errorMsgTarget.classList.remove('hidden')
    switch (error.code) {
      case 1:
        this.errorTextTarget.innerText = "User denied the request for Geolocation."
        break
      case 2:
        this.errorTextTarget.innerText = "Location information is unavailable. Your device's Location settings may be turned off."
        break
      case 3:
        this.errorTextTarget.innerText = "The request to get user location timed out."
        break
      default:
        this.errorTextTarget.innerText = "An unknown error occurred."
    }
  }

  hideError() {
    this.errorMsgTarget.classList.add('hidden')
    this.errorTextTarget.innerText = ""
  }
}