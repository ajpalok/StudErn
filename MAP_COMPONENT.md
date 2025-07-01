# Map Component Documentation

A comprehensive, reusable map component for Rails applications using Stimulus and OpenStreetMap API.

## Features

- ✅ **OpenStreetMap Integration** - No API key required
- ✅ **Current Location Detection** - GPS-based location with fallbacks
- ✅ **Address Search & Reverse Geocoding** - Find locations by address
- ✅ **Draggable Markers** - Fine-tune location selection
- ✅ **Comprehensive Error Handling** - User-friendly error messages
- ✅ **Loading States** - Visual feedback during operations
- ✅ **Form Validation** - Integration with Rails form validation
- ✅ **Responsive Design** - Works on all screen sizes
- ✅ **Accessibility** - ARIA labels and keyboard navigation
- ✅ **Customizable** - Multiple configuration options

## Installation

The component uses the following dependencies (already included in your project):

```json
{
  "leaflet": "^1.9.4",
  "leaflet-control-geocoder": "^3.2.0"
}
```

## Basic Usage

### 1. Simple Map

```erb
<%= form_with url: "#", local: true do |form| %>
  <%= render 'includes/components/map', form: form %>
<% end %>
```

### 2. Required Location with Address

```erb
<%= form_with url: "#", local: true do |form| %>
  <%= render 'includes/components/map', 
      form: form,
      required: true,
      show_address: true %>
<% end %>
```

### 3. Custom Configuration

```erb
<%= form_with url: "#", local: true do |form| %>
  <%= render 'includes/components/map', 
      form: form,
      required: true,
      default_lat: 23.7937,
      default_lng: 90.4066,
      zoom: 14,
      show_address: true,
      height: 'h-80',
      instructions: false %>
<% end %>
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `form` | FormBuilder | Required | The Rails form builder object |
| `required` | Boolean | `false` | Whether location selection is required |
| `default_lat` | Number | `23.7937` | Default latitude (Dhaka) |
| `default_lng` | Number | `90.4066` | Default longitude (Dhaka) |
| `zoom` | Number | `12` | Initial zoom level (1-18) |
| `show_address` | Boolean | `false` | Show address input field |
| `height` | String | `'h-64'` | Map height CSS class |
| `label` | String | `'Location'` | Label for the map |
| `instructions` | Boolean | `true` | Show usage instructions |

## Form Integration

The component automatically creates hidden fields for latitude and longitude:

```erb
<%= form.hidden_field :latitude, data: { map_target: "latitude" } %>
<%= form.hidden_field :longitude, data: { map_target: "longitude" } %>
```

### Model Validation

Add validation to your model:

```ruby
class User < ApplicationRecord
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
end
```

## Stimulus Controller

The component uses a Stimulus controller (`map_controller.js`) with the following targets:

- `latitude` - Hidden field for latitude
- `longitude` - Hidden field for longitude
- `map` - Map container div
- `currentLocation` - "Use Current Location" button
- `errorMsg` - Error message container
- `errorText` - Error message text
- `address` - Address input field (optional)
- `loading` - Loading indicator

### Controller Values

- `required` - Boolean for validation
- `default_lat` - Default latitude
- `default_lng` - Default longitude
- `zoom` - Initial zoom level

### Controller Methods

- `getLocation()` - Get current GPS location
- `clearLocation()` - Clear selected location
- `validateLocation()` - Validate coordinates
- `showError(error)` - Display error message
- `hideError()` - Hide error message

## Error Handling

The component handles various error scenarios:

1. **Geolocation Permission Denied** - User denied location access
2. **Location Unavailable** - Device location settings disabled
3. **Timeout** - Location request timed out
4. **Invalid Coordinates** - Out of range latitude/longitude
5. **Required Field** - Location not selected when required

## Styling

The component uses Tailwind CSS classes and DaisyUI components. Customize by modifying the component partial:

```erb
<!-- Custom styling example -->
<div data-map-target="map" class="w-full h-96 rounded-xl border-4 border-blue-200 shadow-lg"></div>
```

## Accessibility

- ARIA labels for screen readers
- Keyboard navigation support
- High contrast error messages
- Loading state announcements

## Browser Support

- Modern browsers with Geolocation API
- Fallback to default location if GPS unavailable
- Graceful degradation for older browsers

## Performance

- Lazy loading of map tiles
- Debounced geocoding requests
- Efficient marker updates
- Memory cleanup on disconnect

## Examples

### User Profile Form

```erb
<div class="form-group">
  <label>Your Location</label>
  <%= render 'includes/components/map', 
      form: form,
      required: true,
      show_address: true,
      height: 'h-80' %>
</div>
```

### Company Address Form

```erb
<div class="form-group">
  <label>Company Address</label>
  <%= render 'includes/components/map', 
      form: form,
      required: true,
      default_lat: 23.7937,
      default_lng: 90.4066,
      zoom: 15,
      show_address: true,
      instructions: false %>
</div>
```

### Compact Location Picker

```erb
<div class="form-group">
  <label>Meeting Location</label>
  <%= render 'includes/components/map', 
      form: form,
      required: false,
      height: 'h-48',
      instructions: false %>
</div>
```

## Demo

Visit `/map-demo` to see the component in action with different configurations.

## Troubleshooting

### Map Not Loading
- Check if Leaflet CSS is included
- Verify JavaScript bundle includes the controller
- Check browser console for errors

### Location Not Working
- Ensure HTTPS for geolocation
- Check browser location permissions
- Verify device location settings

### Form Validation Issues
- Ensure model has proper validations
- Check that hidden fields are included in permitted parameters
- Verify form submission includes coordinates

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This component is part of the StudErn application and follows the same license terms. 