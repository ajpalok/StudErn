import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet-control-geocoder"

export default class extends Controller {
  static targets = ["latitude", "longitude", "map", "currentLocation", "errorMsg", "errorText", "address", "loading"]
  static values = {
    marker_text: String,
    latitude: Number,
    longitude: Number,
    required: { type: Boolean, default: false },
    default_lat: { type: Number, default: 23.79930876698311 },
    default_lng: { type: Number, default: 90.44951877721275 },
    zoom: { type: Number, default: 15 }
  }

  connect() {
    this.defaultLocation = { lat: this.defaultLatValue, lng: this.defaultLngValue }
    this.map = null
    this.marker = null
    this.isLoading = false
    
    // Check if we have existing coordinates
    if (this.hasLatitudeTarget && this.hasLongitudeTarget && this.latitudeTarget.value && this.longitudeTarget.value) {
      this.defaultLocation.lat = parseFloat(this.latitudeTarget.value)
      this.defaultLocation.lng = parseFloat(this.longitudeTarget.value)
    }
    
    // Initialize map based on whether we have fixed coordinates or need to get location
    if (this.hasLatitudeValue && this.hasLongitudeValue) {
      this.fixedLocation(this.markerTextValue || "Selected Location")
    } else {
      this.initializeMap()
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initializeMap() {
    this.map = L.map(this.mapTarget, {
      center: [this.defaultLocation.lat, this.defaultLocation.lng],
      zoom: this.zoomValue,
      zoomControl: true,
      attributionControl: true
    })

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors | StudErn'
    }).addTo(this.map)

    // Add geocoder control
    this.geocoder = L.Control.geocoder({
      defaultMarkGeocode: false,
      placeholder: "Search for a location...",
      geocoder: L.Control.Geocoder.nominatim({
        geocodingQueryParams: {
          countrycodes: 'bd', // Bangladesh
          limit: 5
        }
      })
    }).on('markgeocode', (e) => {
      const { center } = e.geocode
      this.map.setView(center, this.zoomValue)
      this.updateMarker(center.lat, center.lng)
      this.reverseGeocode(center.lat, center.lng)
    }).addTo(this.map)

    // Add marker
    this.marker = L.marker([this.defaultLocation.lat, this.defaultLocation.lng], {
      draggable: true
    }).addTo(this.map)

    // Set initial values
    this.latitudeTarget.value = this.defaultLocation.lat
    this.longitudeTarget.value = this.defaultLocation.lng

    // Event listeners
    this.map.on('click', (event) => {
      const { lat, lng } = event.latlng
      this.updateMarker(lat, lng)
      this.reverseGeocode(lat, lng)
    })

    this.marker.on('dragend', (event) => {
      const { lat, lng } = event.target.getLatLng()
      this.updateMarker(lat, lng)
      this.reverseGeocode(lat, lng)
    })

    // Try to get current location on initialization
    this.getCurrentLocation()
  }

  getCurrentLocation() {
    if (!navigator.geolocation) {
      this.showError({
        code: 0,
        message: "Geolocation is not supported by this browser."
      })
      return
    }

    this.setLoading(true)
    this.hideError()

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const latitude = parseFloat(position.coords.latitude.toFixed(8))
        const longitude = parseFloat(position.coords.longitude.toFixed(8))

        this.hideError()
        this.setLoading(false)

        this.latitudeTarget.value = latitude
        this.longitudeTarget.value = longitude

        if (this.map) {
          this.map.setView([latitude, longitude], this.zoomValue)
          this.updateMarker(latitude, longitude)
          this.reverseGeocode(latitude, longitude)
        }
      },
      (error) => {
        this.showError(error)
        this.setLoading(false)
        
        // Set default values if geolocation fails
        if (this.hasLatitudeTarget && this.hasLongitudeTarget) {
          this.latitudeTarget.value = this.defaultLocation.lat
          this.longitudeTarget.value = this.defaultLocation.lng
        }
      },
      { 
        enableHighAccuracy: true, 
        timeout: 15000, 
        maximumAge: 60000 
      }
    )
  }

  fixedLocation(popMsg = "Selected Location") {
    const lat = parseFloat(this.latitudeValue || this.defaultLocation.lat)
    const lng = parseFloat(this.longitudeValue || this.defaultLocation.lng)

    if (this.map) return // prevent reinitialization

    this.map = L.map(this.mapTarget, {
      center: [lat, lng],
      zoom: this.zoomValue,
      dragging: false,
      scrollWheelZoom: false,
      doubleClickZoom: true,
      boxZoom: false,
      touchZoom: 'center',
      keyboard: false,
      zoomControl: true
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors | StudErn'
    }).addTo(this.map)

    this.marker = L.marker([lat, lng], { draggable: false }).addTo(this.map).bindPopup(popMsg).openPopup()
  }

  updateMarker(lat, lng) {
    if (this.marker) {
      this.marker.setLatLng([lat, lng])
    }
    
    if (this.hasLatitudeTarget) this.latitudeTarget.value = lat
    if (this.hasLongitudeTarget) this.longitudeTarget.value = lng
    
    // Trigger validation if required
    this.validateLocation()
  }

  async reverseGeocode(lat, lng) {
    try {
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`)
      const data = await response.json()
      
      if (data.display_name && this.hasAddressTarget) {
        this.addressTarget.value = data.display_name
      }
    } catch (error) {
      console.warn('Reverse geocoding failed:', error)
    }
  }

  validateLocation() {
    const lat = parseFloat(this.latitudeTarget.value)
    const lng = parseFloat(this.longitudeTarget.value)
    
    if (this.requiredValue && (!lat || !lng)) {
      this.showError({
        code: 4,
        message: "Please select a location on the map."
      })
      return false
    }
    
    if (lat < -90 || lat > 90) {
      this.showError({
        code: 5,
        message: "Invalid latitude value. Must be between -90 and 90."
      })
      return false
    }
    
    if (lng < -180 || lng > 180) {
      this.showError({
        code: 6,
        message: "Invalid longitude value. Must be between -180 and 180."
      })
      return false
    }
    
    this.hideError()
    return true
  }

  showError(error) {
    if (this.hasErrorMsgTarget) {
      this.errorMsgTarget.classList.remove('hidden')
    }
    
    if (this.hasErrorTextTarget) {
      let message = "An unknown error occurred."
      
      switch (error.code) {
        case 1:
          message = "Location access denied. Please allow location access in your browser settings."
          break
        case 2:
          message = "Location unavailable. Please check your device's location settings."
          break
        case 3:
          message = "Location request timed out. Please try again."
          break
        case 4:
          message = error.message || "Please select a location on the map."
          break
        case 5:
        case 6:
          message = error.message
          break
        default:
          message = error.message || "An unknown error occurred."
      }
      
      this.errorTextTarget.innerText = message
    }
  }

  hideError() {
    if (this.hasErrorMsgTarget) {
      this.errorMsgTarget.classList.add('hidden')
    }
    if (this.hasErrorTextTarget) {
      this.errorTextTarget.innerText = ""
    }
  }

  setLoading(loading) {
    this.isLoading = loading
    if (this.hasLoadingTarget) {
      if (loading) {
        this.loadingTarget.classList.remove('hidden')
      } else {
        this.loadingTarget.classList.add('hidden')
      }
    }
    
    if (this.hasCurrentLocationTarget) {
      this.currentLocationTarget.disabled = loading
      this.currentLocationTarget.innerHTML = loading ? 
        '<span class="loading loading-spinner loading-sm"></span> Getting location...' : 
        '📍 Use Current Location'
    }
  }

  // Public method to get current location (for button clicks)
  getLocation() {
    this.getCurrentLocation()
  }

  // Public method to clear location
  clearLocation() {
    this.latitudeTarget.value = ""
    this.longitudeTarget.value = ""
    if (this.hasAddressTarget) {
      this.addressTarget.value = ""
    }
    this.hideError()
  }
}