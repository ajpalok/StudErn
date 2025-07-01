#!/usr/bin/env ruby

# Simple test script to verify search functionality
# Run this with: ruby test_search_functionality.rb

require_relative 'config/environment'

puts "🧪 Testing Search Functionality"
puts "=" * 50

# Test 1: Search for companies
puts "\n1. Testing company search..."
search_controller = SearchController.new
search_controller.params = { q: "2HAAS" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:companies].any?
  puts "✅ Company search working - Found #{search_controller.instance_variable_get(:@results)[:companies].count} companies"
  search_controller.instance_variable_get(:@results)[:companies].each do |company|
    puts "   - #{company.name}"
  end
else
  puts "❌ Company search failed - No companies found"
end

# Test 2: Search for recruitments
puts "\n2. Testing recruitment search..."
search_controller.params = { q: "Developer" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Recruitment search working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} recruitments"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} at #{recruitment.company.name}"
  end
else
  puts "❌ Recruitment search failed - No recruitments found"
end

# Test 3: Search for description content
puts "\n3. Testing description search..."
search_controller.params = { q: "digital" }
search_controller.index

total_results = search_controller.instance_variable_get(:@results)[:recruitments].count + 
                search_controller.instance_variable_get(:@results)[:companies].count

if total_results > 0
  puts "✅ Description search working - Found #{total_results} total results"
  puts "   - #{search_controller.instance_variable_get(:@results)[:recruitments].count} recruitments"
  puts "   - #{search_controller.instance_variable_get(:@results)[:companies].count} companies"
else
  puts "❌ Description search failed - No results found"
end

# Test 4: Filter by work place
puts "\n4. Testing work place filter..."
search_controller.params = { work_place: "remote" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Work place filter working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} remote recruitments"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} (#{recruitment.work_place})"
  end
else
  puts "❌ Work place filter failed - No remote recruitments found"
end

# Test 5: Filter by work type
puts "\n5. Testing work type filter..."
search_controller.params = { work_type: "full_time" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Work type filter working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} full-time recruitments"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} (#{recruitment.work_type})"
  end
else
  puts "❌ Work type filter failed - No full-time recruitments found"
end

# Test 6: Filter by recruitment type
puts "\n6. Testing recruitment type filter..."
search_controller.params = { recruitment_type: "job" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Recruitment type filter working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} job recruitments"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} (#{recruitment.recruitment_type})"
  end
else
  puts "❌ Recruitment type filter failed - No job recruitments found"
end

# Test 7: Combined search and filter
puts "\n7. Testing combined search and filter..."
search_controller.params = { q: "Developer", work_place: "remote", work_type: "full_time" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Combined search and filter working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} results"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} (#{recruitment.work_place}, #{recruitment.work_type})"
  end
else
  puts "❌ Combined search and filter failed - No results found"
end

# Test 8: Date range filter
puts "\n8. Testing date range filter..."
search_controller.params = { date_range: "month" }
search_controller.index

if search_controller.instance_variable_get(:@results)[:recruitments].any?
  puts "✅ Date range filter working - Found #{search_controller.instance_variable_get(:@results)[:recruitments].count} recent recruitments"
  search_controller.instance_variable_get(:@results)[:recruitments].each do |recruitment|
    puts "   - #{recruitment.title} (posted #{time_ago_in_words(recruitment.created_at)} ago)"
  end
else
  puts "❌ Date range filter failed - No recent recruitments found"
end

# Test 9: Empty search
puts "\n9. Testing empty search..."
search_controller.params = { q: "" }
search_controller.index

results = search_controller.instance_variable_get(:@results)
if results[:recruitments].empty? && results[:companies].empty?
  puts "✅ Empty search working - No results returned"
else
  puts "❌ Empty search failed - Results returned when should be empty"
end

puts "\n" + "=" * 50
puts "🎉 Search functionality test completed!" 