import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Connects to data-controller="onboarding-map"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude"]

  connect() {
    // Default to Dhaka
    const defaultLat = 23.7937;
    const defaultLng = 90.4066;
    const lat = parseFloat(this.latitudeTarget.value) || defaultLat;
    const lng = parseFloat(this.longitudeTarget.value) || defaultLng;

    this.map = L.map(this.mapTarget).setView([lat, lng], 12);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);

    this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map);
    this.marker.on('dragend', this.updateFromMarker.bind(this));
    this.map.on('click', this.setMarker.bind(this));

    // Try to get GPS location
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const pos = [position.coords.latitude, position.coords.longitude];
          this.map.setView(pos, 14);
          this.marker.setLatLng(pos);
          this.latitudeTarget.value = pos[0];
          this.longitudeTarget.value = pos[1];
        },
        () => {},
        { enableHighAccuracy: true }
      );
    }
  }

  updateFromMarker(e) {
    const pos = this.marker.getLatLng();
    this.latitudeTarget.value = pos.lat;
    this.longitudeTarget.value = pos.lng;
  }

  setMarker(e) {
    this.marker.setLatLng(e.latlng);
    this.latitudeTarget.value = e.latlng.lat;
    this.longitudeTarget.value = e.latlng.lng;
  }

  setCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const pos = [position.coords.latitude, position.coords.longitude];
          this.map.setView(pos, 14);
          this.marker.setLatLng(pos);
          this.latitudeTarget.value = pos[0];
          this.longitudeTarget.value = pos[1];
        },
        () => { alert('Unable to get your location.'); },
        { enableHighAccuracy: true }
      );
    } else {
      alert('Geolocation is not supported by this browser.');
    }
  }
} 