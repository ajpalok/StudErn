# Development Seed File for StudErn
# This file creates test data for development environment

puts "🌱 Starting development seed..."

# ============================================================================
# CONTROL UNITS
# ============================================================================

puts "Creating Control Units..."

control_unit_1 = ControlUnit.find_or_create_by!(email: "admin@studern.com") do |cu|
  cu.name = "Admin Control Unit"
  cu.nid = "1234567890123"
  cu.dob = Date.new(1990, 1, 1)
  cu.address = "Dhaka, Bangladesh"
  cu.phone = "01712345678"
  cu.password = "12345678"
  cu.role = 99 # Super admin
  cu.status = true
  cu.confirmed_at = Time.current
end

control_unit_2 = ControlUnit.find_or_create_by!(email: "moderator@studern.com") do |cu|
  cu.name = "Moderator Control Unit"
  cu.nid = "1234567890124"
  cu.dob = Date.new(1992, 5, 15)
  cu.address = "Chittagong, Bangladesh"
  cu.phone = "01712345679"
  cu.password = "12345678"
  cu.role = 50 # Moderator
  cu.status = true
  cu.confirmed_at = Time.current
end

# ============================================================================
# COMPANIES
# ============================================================================

puts "Creating Companies..."

# 2HAAS Company (from 2haas.com)
company_2haas = Company.find_or_create_by!(name: "2HAAS") do |c|
  c.tagline = "Innovative Digital Solutions"
  c.description = "2HAAS is a leading digital agency specializing in web development, mobile apps, and digital marketing solutions. We help businesses transform their digital presence with cutting-edge technology and creative solutions."
  c.email = "info@2haas.com"
  c.phone = "01712345670"
  c.website = "https://2haas.com"
  c.latitude = 23.7937
  c.longitude = 90.4066
end

# Mosfism Company
company_mosfism = Company.find_or_create_by!(name: "Mosfism") do |c|
  c.tagline = "Creative Digital Agency"
  c.description = "Mosfism is a creative digital agency focused on branding, web design, and digital marketing. We create meaningful digital experiences that connect brands with their audiences."
  c.email = "hello@mosfism.2haas.com"
  c.phone = "01712345671"
  c.website = "https://mosfism.2haas.com"
  c.latitude = 23.7938
  c.longitude = 90.4067
end

# Create additional companies with Faker
5.times do |i|
  Company.find_or_create_by!(name: Faker::Company.name) do |c|
    c.tagline = Faker::Company.catch_phrase
    c.description = Faker::Company.bs
    c.email = Faker::Internet.email(domain: "#{Faker::Internet.domain_name}")
    c.phone = "01#{rand(100000000..999999999)}"
    c.website = "https://#{Faker::Internet.domain_name}"
    c.latitude = 23.7937 + rand(-0.01..0.01)
    c.longitude = 90.4066 + rand(-0.01..0.01)
  end
end

# ============================================================================
# RECRUITERS
# ============================================================================

puts "Creating Recruiters..."

# Abrar Jahin - 2HAAS Recruiter
recruiter_abrar = Recruiter.find_or_create_by!(email: "palok1969@gmail.com") do |r|
  r.first_name = "Abrar"
  r.last_name = "Jahin"
  r.phone = "01712345672"
  r.gender = rand(1..3)
  r.account_status = "complete"
  r.password = "12345678"
  r.confirmed_at = Time.current
end

# Sumaya Zaman - Mosfism Recruiter
recruiter_sumaya = Recruiter.find_or_create_by!(email: "zsumaya0@gmail.com") do |r|
  r.first_name = "Sumaya"
  r.last_name = "Zaman"
  r.phone = "01712345673"
  r.gender = rand(1..3)
  r.account_status = "complete"
  r.password = "12345678"
  r.confirmed_at = Time.current
end

# Create additional recruiters with Faker
8.times do |i|
  Recruiter.find_or_create_by!(email: Faker::Internet.email) do |r|
    r.first_name = Faker::Name.first_name
    r.last_name = Faker::Name.last_name
    r.phone = "01#{rand(100000000..999999999)}"
    r.gender = rand(1..3)
    r.account_status = ["incomplete", "complete", "suspended"].sample
    r.password = "12345678"
    r.confirmed_at = Time.current
  end
end

# ============================================================================
# RECRUITER PERMISSIONS ON COMPANIES
# ============================================================================

puts "Setting up Recruiter-Company relationships..."

# Abrar Jahin - 2HAAS
RecruiterPermissionsOnCompany.find_or_create_by!(recruiter_id: recruiter_abrar.id, company_id: company_2haas.id) do |rpc|
  rpc.recruiter_position = "Senior HR Manager"
  rpc.recruiter_working_start_time = Time.parse("09:00")
  rpc.recruiter_working_end_time = Time.parse("18:00")
  rpc.recruiter_status = "approved"
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

# Sumaya Zaman - Mosfism
RecruiterPermissionsOnCompany.find_or_create_by!(recruiter_id: recruiter_sumaya.id, company_id: company_mosfism.id) do |rpc|
  rpc.recruiter_position = "HR Director"
  rpc.recruiter_working_start_time = Time.parse("08:30")
  rpc.recruiter_working_end_time = Time.parse("17:30")
  rpc.recruiter_status = "approved"
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

# Assign other recruiters to random companies
Recruiter.where.not(id: [recruiter_abrar.id, recruiter_sumaya.id]).each do |recruiter|
  company = Company.all.sample
  next if RecruiterPermissionsOnCompany.exists?(recruiter: recruiter, company: company)
  
  RecruiterPermissionsOnCompany.create!(
    recruiter: recruiter,
    company: company,
    recruiter_position: ["HR Manager", "Talent Acquisition Specialist", "Recruitment Lead", "HR Coordinator"].sample,
    recruiter_working_start_time: Time.parse("#{rand(8..10)}:00"),
    recruiter_working_end_time: Time.parse("#{rand(17..19)}:00"),
    recruiter_status: ["pending", "approved", "rejected"].sample,
    can_manage_jobs: [true, false].sample,
    can_manage_applicants: [true, false].sample,
    can_manage_interviews: [true, false].sample,
    can_manage_offers: [true, false].sample,
    can_manage_company_profile: [true, false].sample,
    can_manage_recruiter_profile: [true, false].sample,
    can_manage_company_settings: [true, false].sample,
    can_manage_recruiter_settings: [true, false].sample,
    can_manage_company_users: [true, false].sample,
    can_manage_subscriptions_of_studern: [true, false].sample
  )
end

# ============================================================================
# USERS
# ============================================================================

puts "Creating Users..."

# Create users with Faker
20.times do |i|
  User.find_or_create_by!(email: Faker::Internet.email) do |u|
    u.first_name = Faker::Name.first_name
    u.last_name = Faker::Name.last_name
    u.phone = "01#{rand(100000000..999999999)}"
    u.latitude = 23.7937 + rand(-0.01..0.01)
    u.longitude = 90.4066 + rand(-0.01..0.01)
    u.career_objective = Faker::Lorem.paragraph(sentence_count: 3)
    u.dob = Date.new(rand(1990..2005), rand(1..12), rand(1..28))
    u.gender = rand(1..3)
    u.account_status = ["incomplete", "complete", "suspended"].sample
    u.password = "12345678"
    u.confirmed_at = Time.current
  end
end

# ============================================================================
# USER EDUCATION
# ============================================================================

puts "Creating User Education records..."

User.all.each do |user|
  rand(1..3).times do
    UserEducation.find_or_create_by!(
      user: user,
      institution_name: Faker::University.name,
      degree: ["Bachelor's in Computer Science", "Master's in Business Administration", "Bachelor's in Engineering", "Diploma in IT"].sample
    ) do |ue|
      ue.performance_type = rand(0..2)
      ue.performance = rand(3.0..4.0).round(2)
      ue.start_date = Date.new(rand(2015..2020), rand(1..12), 1)
      ue.end_date = Date.new(rand(2020..2024), rand(1..12), 1)
      ue.currently_studying = [true, false].sample
    end
  end
end

# ============================================================================
# USER WORK EXPERIENCES
# ============================================================================

puts "Creating User Work Experience records..."

User.all.each do |user|
  rand(0..2).times do
    UserWorkExperience.find_or_create_by!(
      user: user,
      company_name: Faker::Company.name,
      designation: ["Software Engineer", "Marketing Manager", "Sales Executive", "Designer", "Analyst"].sample
    ) do |uwe|
      uwe.start_date = Date.new(rand(2018..2022), rand(1..12), 1)
      uwe.end_date = Date.new(rand(2022..2024), rand(1..12), 1)
      uwe.currently_working = [true, false].sample
      uwe.job_responsibilities = Faker::Lorem.paragraph(sentence_count: 2)
      uwe.employment_type = rand(0..3)
    end
  end
end

# ============================================================================
# USER SKILLS
# ============================================================================

puts "Creating User Skills..."

skills = ["Ruby on Rails", "JavaScript", "React", "Python", "Java", "PHP", "HTML/CSS", "SQL", "Git", "Docker", "AWS", "Node.js", "Vue.js", "Angular", "MongoDB", "PostgreSQL", "MySQL", "Redis", "GraphQL", "REST API"]

User.all.each do |user|
  rand(3..8).times do
    skill_name = skills.sample
    next if UserSkill.exists?(user: user, skill_name: skill_name)
    
    UserSkill.create!(
      user: user,
      skill_name: skill_name,
      skill_level: rand(0..4)
    )
  end
end

# ============================================================================
# USER ACCOMPLISHMENTS
# ============================================================================

puts "Creating User Accomplishments..."

User.all.each do |user|
  rand(0..2).times do
    UserAccomplishment.create!(
      user: user,
      accomplishment_type: rand(0..3),
      accomplishment_url: Faker::Internet.url,
      accomplishment_name: Faker::Lorem.sentence(word_count: 3),
      accomplishment_description: Faker::Lorem.paragraph(sentence_count: 2),
      accomplishment_start_date: Date.new(rand(2020..2023), rand(1..12), 1),
      accomplishment_end_date: Date.new(rand(2023..2024), rand(1..12), 1),
      ongoing: [true, false].sample
    )
  end
end

# ============================================================================
# BKASH PAYMENTS
# ============================================================================

puts "Creating Bkash Payments..."

# Create payments for recruitments
def create_bkash_payment(recruitment_type, amount = nil)
  BkashPayment.create!(
    payment_from: "recruitment",
    payment_id: "TR#{rand(100000..999999)}#{Time.current.to_i}",
    trx_id: "BKASH#{rand(100000000..999999999)}",
    trx_status: "success",
    amount: amount || rand(100..1000),
    verification_status: "verified",
    refund_status: "none",
    refund_amount: "0",
    refund_charge: "0",
    refund_id: nil,
    refund_reason: nil
  )
end

# ============================================================================
# RECRUITMENTS
# ============================================================================

puts "Creating Recruitments..."

# 2HAAS Recruitments
recruitment_types = ["job", "internship", "micro_job", "micro_internship"]
work_types = ["full_time", "part_time", "project", "freelance"]
work_places = ["on_site", "remote", "hybrid"]
salary_types = ["fixed", "negotiable", "hourly", "weekly", "monthly", "yearly"]
experience_levels = ["entry_level", "mid_level", "senior_level", "expert_level"]
application_packages = ["basic", "standard", "premium"]
application_collection_methods = ["easy_apply", "external_link", "email"]

# Create recruitments for 2HAAS
5.times do |i|
  recruitment_type = recruitment_types.sample
  application_method = application_collection_methods.sample
  
  recruitment = Recruitment.create!(
    recruitment_type: recruitment_type,
    title: ["Senior Ruby Developer", "Frontend React Developer", "UI/UX Designer", "DevOps Engineer", "Product Manager"].sample,
    description: Faker::Lorem.paragraph(sentence_count: 5),
    experience_level: experience_levels.sample,
    work_type: work_types.sample,
    work_place: work_places.sample,
    latitude: 23.7937 + rand(-0.01..0.01),
    longitude: 90.4066 + rand(-0.01..0.01),
    salary_type: salary_types.sample,
    annual_salary_range_start: rand(300000..800000),
    annual_salary_range_end: rand(800000..1500000),
    number_of_vacancies: rand(1..5),
    application_collection_status: "open",
    application_collection_end_date: Date.current + rand(30..90).days,
    application_package: application_packages.sample,
    application_collection_method: application_method,
    application_link: application_method == "external_link" ? Faker::Internet.url : (application_method == "email" ? Faker::Internet.email : nil),
    calling_number: "01#{rand(100000000..999999999)}",
    company: company_2haas,
    recruiter: recruiter_abrar
  )
  
  # Create payment for this recruitment
  payment = create_bkash_payment("recruitment", rand(100..500))
  recruitment.update!(bkash_payment: payment)
end

# Create recruitments for Mosfism
5.times do |i|
  recruitment_type = recruitment_types.sample
  application_method = application_collection_methods.sample
  
  recruitment = Recruitment.create!(
    recruitment_type: recruitment_type,
    title: ["Creative Designer", "Marketing Specialist", "Content Writer", "SEO Expert", "Social Media Manager"].sample,
    description: Faker::Lorem.paragraph(sentence_count: 5),
    experience_level: experience_levels.sample,
    work_type: work_types.sample,
    work_place: work_places.sample,
    latitude: 23.7938 + rand(-0.01..0.01),
    longitude: 90.4067 + rand(-0.01..0.01),
    salary_type: salary_types.sample,
    annual_salary_range_start: rand(250000..600000),
    annual_salary_range_end: rand(600000..1200000),
    number_of_vacancies: rand(1..3),
    application_collection_status: "open",
    application_collection_end_date: Date.current + rand(30..90).days,
    application_package: application_packages.sample,
    application_collection_method: application_method,
    application_link: application_method == "external_link" ? Faker::Internet.url : (application_method == "email" ? Faker::Internet.email : nil),
    calling_number: "01#{rand(100000000..999999999)}",
    company: company_mosfism,
    recruiter: recruiter_sumaya
  )
  
  # Create payment for this recruitment
  payment = create_bkash_payment("recruitment", rand(100..500))
  recruitment.update!(bkash_payment: payment)
end

# Create recruitments for other companies
Company.where.not(id: [company_2haas.id, company_mosfism.id]).each do |company|
  recruiter_permission = RecruiterPermissionsOnCompany.find_by(company: company, recruiter_status: "approved")
  next unless recruiter_permission
  
  rand(1..3).times do
    recruitment_type = recruitment_types.sample
    application_method = application_collection_methods.sample
    
    recruitment = Recruitment.create!(
      recruitment_type: recruitment_type,
      title: Faker::Job.title,
      description: Faker::Lorem.paragraph(sentence_count: 5),
      experience_level: experience_levels.sample,
      work_type: work_types.sample,
      work_place: work_places.sample,
      latitude: 23.7937 + rand(-0.01..0.01),
      longitude: 90.4066 + rand(-0.01..0.01),
      salary_type: salary_types.sample,
      annual_salary_range_start: rand(200000..800000),
      annual_salary_range_end: rand(800000..1500000),
      number_of_vacancies: rand(1..4),
      application_collection_status: ["open", "close", "draft"].sample,
      application_collection_end_date: Date.current + rand(30..90).days,
      application_package: application_packages.sample,
      application_collection_method: application_method,
      application_link: application_method == "external_link" ? Faker::Internet.url : (application_method == "email" ? Faker::Internet.email : nil),
      calling_number: "01#{rand(100000000..999999999)}",
      company: company,
      recruiter: recruiter_permission.recruiter
    )
    
    # Create payment for this recruitment (only if status is open)
    if recruitment.application_collection_status == "open"
      payment = create_bkash_payment("recruitment", rand(100..500))
      recruitment.update!(bkash_payment: payment)
    end
  end
end

# ============================================================================
# RECRUITMENT APPLIES
# ============================================================================

puts "Creating Recruitment Applications..."

# Create some applications for easy_apply recruitments
Recruitment.where(application_collection_method: "easy_apply", application_collection_status: "open").each do |recruitment|
  # Get users with complete profiles
  eligible_users = User.where(account_status: "complete").sample(rand(1..5))
  
  eligible_users.each do |user|
    next if RecruitmentApply.exists?(user: user, recruitment: recruitment)
    
    RecruitmentApply.create!(
      user: user,
      recruitment: recruitment,
      status: ["pending", "accepted", "rejected"].sample,
      has_contacted_yet: [true, false].sample,
      message: [nil, Faker::Lorem.sentence].sample
    )
  end
end

puts "✅ Development seed completed successfully!"
puts "📊 Summary:"
puts "   - Control Units: #{ControlUnit.count}"
puts "   - Companies: #{Company.count}"
puts "   - Recruiters: #{Recruiter.count}"
puts "   - Users: #{User.count}"
puts "   - Recruitments: #{Recruitment.count}"
puts "   - Applications: #{RecruitmentApply.count}"
puts ""
puts "🔑 Login Credentials:"
puts "   - Abrar Jahin (2HAAS): palok1969@gmail.com / 12345678"
puts "   - Sumaya Zaman (Mosfism): zsumaya0@gmail.com / 12345678"
puts "   - Admin: admin@studern.com / 12345678"
puts "   - Moderator: moderator@studern.com / 12345678"
puts ""
puts "🌐 All other users have password: 12345678"
