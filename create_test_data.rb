#!/usr/bin/env ruby

# Script to create test data for search functionality
require_relative 'config/environment'

puts "Creating test data for search functionality..."

# Create a test company
company = Company.find_or_create_by!(name: "TestTech Solutions") do |c|
  c.tagline = "Innovative Technology Solutions"
  c.description = "TestTech Solutions is a leading technology company specializing in digital transformation and software development."
  c.email = "info@testtech.com"
  c.phone = "01712345678"
  c.website = "https://testtech.com"
  c.latitude = 23.7937
  c.longitude = 90.4066
end

puts "Created company: #{company.name}"

# Create a test recruiter
recruiter = Recruiter.find_or_create_by!(email: "recruiter@testtech.com") do |r|
  r.first_name = "John"
  r.last_name = "Doe"
  r.phone = "01712345679"
  r.gender = 1
  r.account_status = 1 # complete
  r.password = "12345678"
  r.confirmed_at = Time.current
end

puts "Created recruiter: #{recruiter.first_name} #{recruiter.last_name}"

# Create recruiter permission
permission = RecruiterPermissionsOnCompany.find_or_create_by!(recruiter: recruiter, company: company) do |rpc|
  rpc.recruiter_position = "HR Manager"
  rpc.recruiter_working_start_time = Time.parse("09:00")
  rpc.recruiter_working_end_time = Time.parse("18:00")
  rpc.recruiter_status = 1 # approved
  rpc.can_manage_jobs = true
  rpc.can_manage_applicants = true
  rpc.can_manage_interviews = true
  rpc.can_manage_offers = true
  rpc.can_manage_company_profile = true
  rpc.can_manage_recruiter_profile = true
  rpc.can_manage_company_settings = true
  rpc.can_manage_recruiter_settings = true
  rpc.can_manage_company_users = true
  rpc.can_manage_subscriptions_of_studern = true
end

puts "Created recruiter permission"

# Create test recruitments
recruitment_data = [
  {
    title: "Senior Ruby Developer",
    description: "We are looking for an experienced Ruby developer to join our team. Must have experience with Rails and modern web technologies.",
    recruitment_type: 0, # job
    work_type: 0, # full_time
    work_place: 1, # remote
    experience_level: 2, # senior_level
    salary_type: 5 # yearly
  },
  {
    title: "Frontend React Developer",
    description: "Join our frontend team to build amazing user interfaces with React and modern JavaScript frameworks.",
    recruitment_type: 0, # job
    work_type: 0, # full_time
    work_place: 2, # hybrid
    experience_level: 1, # mid_level
    salary_type: 4 # monthly
  },
  {
    title: "UIUX Design Intern",
    description: "Great opportunity for design students to gain real-world experience in UI/UX design and user research.",
    recruitment_type: 1, # internship
    work_type: 1, # part_time
    work_place: 0, # on_site
    experience_level: 0, # entry_level
    salary_type: 0 # fixed
  },
  {
    title: "DevOps Engineer",
    description: "We need a DevOps engineer to help us scale our infrastructure and improve our deployment processes.",
    recruitment_type: 0, # job
    work_type: 0, # full_time
    work_place: 1, # remote
    experience_level: 3, # expert_level
    salary_type: 5 # yearly
  },
  {
    title: "Content Writer",
    description: "Looking for a creative content writer to help us create engaging blog posts and marketing materials.",
    recruitment_type: 2, # micro_job
    work_type: 3, # freelance
    work_place: 1, # remote
    experience_level: 0, # entry_level
    salary_type: 2 # hourly
  }
]

recruitment_data.each_with_index do |data, index|
  # Create payment
  payment = BkashPayment.create!(
    payment_from: "recruitment",
    payment_id: "TR#{rand(100000..999999)}#{Time.current.to_i}",
    trx_id: "BKASH#{rand(100000000..999999999)}",
    trx_status: "success",
    amount: [3850, 4500, 5300].sample,
    verification_status: "verified",
    refund_status: "none",
    refund_amount: "0",
    refund_charge: "0",
    refund_id: nil,
    refund_reason: nil
  )

  # Only set annual salary range if not fixed
  annual_salary_range_start = nil
  annual_salary_range_end = nil
  if data[:salary_type] != 0 # not fixed
    annual_salary_range_start = rand(300000..800000)
    annual_salary_range_end = rand(800000..1500000)
  end

  # Create recruitment
  recruitment = Recruitment.create!(
    recruitment_type: data[:recruitment_type],
    title: data[:title],
    description: data[:description],
    experience_level: data[:experience_level],
    work_type: data[:work_type],
    work_place: data[:work_place],
    latitude: 23.7937 + rand(-0.01..0.01),
    longitude: 90.4066 + rand(-0.01..0.01),
    salary_type: data[:salary_type],
    annual_salary_range_start: annual_salary_range_start,
    annual_salary_range_end: annual_salary_range_end,
    number_of_vacancies: rand(1..5),
    application_collection_status: 1, # open
    application_collection_end_date: Date.current + rand(30..90).days,
    application_package: [0, 1, 2].sample, # basic, standard, premium
    application_collection_method: 0, # easy_apply
    application_link: nil,
    calling_number: "0171234567#{index + 1}",
    company: company,
    recruiter: recruiter,
    bkash_payment: payment
  )

  puts "Created recruitment: #{recruitment.title} (#{recruitment.work_place}, #{recruitment.work_type})"
end

puts "\nTest data creation completed!"
puts "Total companies: #{Company.count}"
puts "Total recruitments: #{Recruitment.count}"
puts "Total recruiters: #{Recruiter.count}"

# Create test data for StudErn application
puts "Creating test data..."

# Create companies
companies = []
5.times do |i|
  company = Company.create!(
    name: "Test Company #{i + 1}",
    tagline: "Innovative solutions for the future",
    description: "We are a leading technology company focused on creating innovative solutions for businesses and individuals. Our team works hard to deliver quality products.",
    website: "https://testcompany#{i + 1}.com",
    email: "contact@testcompany#{i + 1}.com",
    phone: "0171234567#{i}",
    latitude: 23.7937 + rand(-0.01..0.01),
    longitude: 90.4066 + rand(-0.01..0.01)
  )
  companies << company
  puts "Created company: #{company.name}"
end

# Create recruiters
recruiters = []
5.times do |i|
  recruiter = Recruiter.create!(
    email: "recruiter#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Recruiter",
    last_name: "#{i + 1}",
    phone: "0171234567#{i}",
    gender: rand(1..3),
    account_status: 1, # complete
    confirmed_at: Time.current
  )
  recruiters << recruiter
  puts "Created recruiter: #{recruiter.email}"
end

# Create recruiter permissions on companies
companies.each_with_index do |company, i|
  RecruiterPermissionsOnCompany.create!(
    company: company,
    recruiter: recruiters[i],
    recruiter_position: "HR Manager",
    recruiter_working_start_time: Time.parse("09:00"),
    recruiter_working_end_time: Time.parse("18:00"),
    recruiter_status: 1, # approved
    can_manage_jobs: true,
    can_manage_applicants: true,
    can_manage_interviews: true,
    can_manage_offers: true,
    can_manage_company_profile: true,
    can_manage_recruiter_profile: true,
    can_manage_company_settings: true,
    can_manage_recruiter_settings: true,
    can_manage_company_users: true,
    can_manage_subscriptions_of_studern: true
  )
  puts "Created recruiter permission for #{company.name}"
end

# Create users
users = []
10.times do |i|
  user = User.create!(
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "User",
    last_name: "#{i + 1}",
    phone: "0171234567#{i}",
    latitude: 23.7937 + rand(-0.01..0.01),
    longitude: 90.4066 + rand(-0.01..0.01),
    career_objective: "I am passionate about technology and innovation.",
    dob: Date.new(rand(1990..2000), rand(1..12), rand(1..28)),
    gender: rand(1..3),
    account_status: 1, # complete
    confirmed_at: Time.current
  )
  users << user
  puts "Created user: #{user.email}"
end

# Create recruitments for each company
companies.each_with_index do |company, i|
  recruiter = recruiters[i]
  
  3.times do |j|
    # Create payment
    payment = BkashPayment.create!(
      payment_from: "recruitment",
      payment_id: "TR#{rand(100000..999999)}#{Time.current.to_i}",
      trx_id: "BKASH#{rand(100000000..999999999)}",
      trx_status: "success",
      amount: [3850, 4500, 5300].sample,
      verification_status: "verified",
      refund_status: "none",
      refund_amount: "0",
      refund_charge: "0",
      refund_id: nil,
      refund_reason: nil
    )
    
    recruitment = Recruitment.create!(
      recruitment_type: [0, 1, 2, 3].sample, # job, internship, micro_job, micro_internship
      title: "Test Position #{j + 1} at #{company.name}",
      description: "This is a test position for #{company.name}. We are looking for talented individuals to join our team.",
      experience_level: [0, 1, 2, 3].sample, # entry_level, mid_level, senior_level, expert_level
      work_type: [0, 1, 2, 3].sample, # full_time, part_time, project, freelance
      work_place: [0, 1, 2].sample, # on_site, remote, hybrid
      latitude: 23.7937 + rand(-0.01..0.01),
      longitude: 90.4066 + rand(-0.01..0.01),
      salary_type: [0, 1, 2, 3, 4, 5].sample, # fixed, negotiable, hourly, weekly, monthly, yearly
      annual_salary_range_start: rand(200000..800000),
      annual_salary_range_end: rand(800000..1500000),
      number_of_vacancies: rand(1..5),
      application_collection_status: 1, # open
      application_collection_end_date: Date.current + rand(30..90).days,
      application_package: [0, 1, 2].sample, # basic, standard, premium
      application_collection_method: 0, # easy_apply
      application_link: nil,
      calling_number: "0171234567#{i}#{j}",
      company: company,
      recruiter: recruiter,
      bkash_payment: payment
    )
    
    puts "Created recruitment: #{recruitment.title}"
  end
end

puts "\nAll test data created successfully!"
puts "Summary:"
puts "- Companies: #{Company.count}"
puts "- Recruiters: #{Recruiter.count}"
puts "- Users: #{User.count}"
puts "- Recruitments: #{Recruitment.count}"
puts "- Applications: #{RecruitmentApply.count}" 