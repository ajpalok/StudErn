module LocationHelper
  # Earth's radius in kilometers
  EARTH_RADIUS = 6371.0

  # Calculate distance between two points using Haversine formula
  # Returns distance in kilometers
  def calculate_distance(lat1, lon1, lat2, lon2)
    # Convert degrees to radians
    lat1_rad = lat1 * Math::PI / 180
    lon1_rad = lon1 * Math::PI / 180
    lat2_rad = lat2 * Math::PI / 180
    lon2_rad = lon2 * Math::PI / 180

    # Haversine formula
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    a = Math.sin(dlat/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon/2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    
    # Distance in kilometers
    EARTH_RADIUS * c
  end

  # Check if a point is within a certain radius of another point
  def within_radius?(lat1, lon1, lat2, lon2, radius_km)
    distance = calculate_distance(lat1, lon1, lat2, lon2)
    distance <= radius_km
  end

  # Format distance for display
  def format_distance(distance_km)
    if distance_km < 1
      "#{(distance_km * 1000).round} m"
    else
      "#{distance_km.round(1)} km"
    end
  end
end 