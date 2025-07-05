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
  cu.role = 0 # Super admin
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
  cu.role = 1 # Admin
  cu.status = true
  cu.confirmed_at = Time.current
end

# Sample courses for development
puts "Creating sample courses..."

# Get the first control unit (super admin)
control_unit = ControlUnit.super_admin.first || ControlUnit.first

if control_unit
  courses_data = [
    {
      title: "Digital Marketing Masterclass",
      description: "Learn the fundamentals of digital marketing including SEO, social media marketing, content marketing, and email marketing. This comprehensive course will teach you how to create effective digital marketing strategies.",
      duration: "8 weeks",
      price: 5000.0,
      instructor: "Sarah Johnson",
      category: "Marketing",
      status: "published",
      featured: true,
      syllabus: "Week 1: Introduction to Digital Marketing\nWeek 2: SEO Fundamentals\nWeek 3: Social Media Marketing\nWeek 4: Content Marketing\nWeek 5: Email Marketing\nWeek 6: PPC Advertising\nWeek 7: Analytics and Measurement\nWeek 8: Strategy Development",
      max_students: 30,
      start_date: 1.month.from_now,
      end_date: 3.months.from_now,
      image_url: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500"
    },
    {
      title: "Web Development Bootcamp",
      description: "Master modern web development with HTML, CSS, JavaScript, and React. Build responsive websites and web applications from scratch.",
      duration: "12 weeks",
      price: 8000.0,
      instructor: "Michael Chen",
      category: "Programming",
      status: "published",
      featured: true,
      syllabus: "Week 1-2: HTML & CSS Fundamentals\nWeek 3-4: JavaScript Basics\nWeek 5-6: Advanced JavaScript\nWeek 7-8: React Fundamentals\nWeek 9-10: React Advanced\nWeek 11-12: Project Development",
      max_students: 25,
      start_date: 2.weeks.from_now,
      end_date: 3.months.from_now,
      image_url: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=500"
    },
    {
      title: "UI/UX Design Principles",
      description: "Learn the principles of user interface and user experience design. Create beautiful, functional, and user-friendly digital products.",
      duration: "6 weeks",
      price: 4000.0,
      instructor: "Emily Rodriguez",
      category: "Design",
      status: "published",
      featured: false,
      syllabus: "Week 1: Design Fundamentals\nWeek 2: User Research\nWeek 3: Wireframing\nWeek 4: Prototyping\nWeek 5: User Testing\nWeek 6: Final Project",
      max_students: 20,
      start_date: 1.week.from_now,
      end_date: 2.months.from_now,
      image_url: "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500"
    },
    {
      title: "Business Strategy & Management",
      description: "Develop essential business skills including strategic planning, project management, and leadership. Perfect for entrepreneurs and business professionals.",
      duration: "10 weeks",
      price: 6000.0,
      instructor: "David Thompson",
      category: "Business",
      status: "published",
      featured: false,
      syllabus: "Week 1: Business Fundamentals\nWeek 2: Strategic Planning\nWeek 3: Market Analysis\nWeek 4: Financial Management\nWeek 5: Operations Management\nWeek 6: Leadership Skills\nWeek 7: Team Management\nWeek 8: Risk Management\nWeek 9: Innovation & Growth\nWeek 10: Business Plan Development",
      max_students: 35,
      start_date: 3.weeks.from_now,
      end_date: 3.months.from_now,
      image_url: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=500"
    },
    {
      title: "Python for Data Science",
      description: "Learn Python programming and data science techniques. Master data analysis, visualization, and machine learning fundamentals.",
      duration: "10 weeks",
      price: 7000.0,
      instructor: "Dr. Lisa Wang",
      category: "Programming",
      status: "published",
      featured: true,
      syllabus: "Week 1: Python Basics\nWeek 2: Data Structures\nWeek 3: Pandas & NumPy\nWeek 4: Data Visualization\nWeek 5: Statistical Analysis\nWeek 6: Machine Learning Intro\nWeek 7: Supervised Learning\nWeek 8: Unsupervised Learning\nWeek 9: Deep Learning Basics\nWeek 10: Capstone Project",
      max_students: 28,
      start_date: 1.month.from_now,
      end_date: 3.months.from_now,
      image_url: "https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=500"
    },
    {
      title: "Photography Fundamentals",
      description: "Master the basics of photography including composition, lighting, and camera settings. Perfect for beginners and hobbyists.",
      duration: "6 weeks",
      price: 3000.0,
      instructor: "Alex Martinez",
      category: "Photography",
      status: "published",
      featured: false,
      syllabus: "Week 1: Camera Basics\nWeek 2: Composition Rules\nWeek 3: Lighting Techniques\nWeek 4: Portrait Photography\nWeek 5: Landscape Photography\nWeek 6: Photo Editing",
      max_students: 15,
      start_date: 2.weeks.from_now,
      end_date: 2.months.from_now,
      image_url: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500"
    }
  ]

  courses_data.each do |course_data|
    course = Course.find_or_create_by(title: course_data[:title]) do |c|
      c.assign_attributes(course_data.merge(control_unit: control_unit))
    end

    if course.persisted?
      puts "✓ Course '#{course.title}' created/updated"
    else
      puts "✗ Failed to create course '#{course.title}': #{course.errors.full_messages.join(', ')}"
    end
  end

  puts "Sample courses created successfully!"
else
  puts "No control unit found. Please create a control unit first."
end

# ============================================================================
# COMPANIES
# ============================================================================

puts "Creating Companies..."

# 2HAAS Company (from 2haas.com)
company_2haas = Company.find_or_create_by!(name: "2HAAS") do |c|
  c.tagline = "Innovative Digital Solutions"
  c.description = "2HAAS is a leading digital agency specializing in web development, mobile apps, and digital marketing solutions. We help businesses transform their digital presence with cutting-edge technology and creative solutions."
  c.email = "contact@2haas.com"
  c.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
  c.website = "https://2haas.com"
  c.latitude = 23.7937
  c.longitude = 90.4066
end

# Mosfism Company
company_mosfism = Company.find_or_create_by!(name: "Mosfism") do |c|
  c.tagline = "Creative Digital Agency"
  c.description = "Mosfism is a creative digital agency focused on branding web design and digital marketing. We create meaningful digital experiences that connect brands with their audiences."
  c.email = "contact@mosfism.2haas.com"
  c.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
  c.website = "https://mosfism.2haas.com"
  c.latitude = 23.7938
  c.longitude = 90.4067
end

# Create additional companies with Faker
5.times do |i|
  company_name = Faker::Company.name.gsub(/[^\w\s]/, '').strip
  email_name = company_name.downcase.gsub(/\s+/, '')
  Company.find_or_create_by!(name: company_name) do |c|
    c.tagline = Faker::Company.catch_phrase.gsub(/[^\w.\-#&\s]/, '')
    c.description = "A leading technology company focused on innovation and digital transformation. We provide cutting-edge solutions for businesses worldwide."
    c.email = "contact@#{email_name}.com"
    c.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
    c.website = "https://#{email_name}.com"
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
  r.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
  r.gender = 1
  r.account_status = 1 # complete
  r.password = "12345678"
  r.confirmed_at = Time.current
end

# Sumaya Zaman - Mosfism Recruiter
recruiter_sumaya = Recruiter.find_or_create_by!(email: "zsumaya0@gmail.com") do |r|
  r.first_name = "Sumaya"
  r.last_name = "Zaman"
  r.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
  r.gender = rand(1..3)
  r.account_status = 1 # complete
  r.password = "12345678"
  r.confirmed_at = Time.current
end

# Create additional recruiters with Faker
8.times do |i|
  first_name = Faker::Name.first_name.gsub(/[^a-zA-Z0-9.\-#&\s]/, '')
  last_name = Faker::Name.last_name.gsub(/[^a-zA-Z0-9.\-#&\s]/, '')
  email_name = "#{first_name}#{last_name}".downcase.gsub(/[^a-z0-9]/, '')
  Recruiter.find_or_create_by!(email: "contact@#{email_name}.com") do |r|
    r.first_name = first_name
    r.last_name = last_name
    r.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
    r.gender = rand(1..3)
    r.account_status = [ 0, 1, 2 ].sample # incomplete, complete, suspended
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

# Sumaya Zaman - Mosfism
RecruiterPermissionsOnCompany.find_or_create_by!(recruiter_id: recruiter_sumaya.id, company_id: company_mosfism.id) do |rpc|
  rpc.recruiter_position = "HR Director"
  rpc.recruiter_working_start_time = Time.parse("08:30")
  rpc.recruiter_working_end_time = Time.parse("17:30")
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

# Assign other recruiters to random companies
Recruiter.where.not(id: [ recruiter_abrar.id, recruiter_sumaya.id ]).each do |recruiter|
  company = Company.all.sample
  next if RecruiterPermissionsOnCompany.exists?(recruiter: recruiter, company: company)

  RecruiterPermissionsOnCompany.create!(
    recruiter: recruiter,
    company: company,
    recruiter_position: [ "HR Manager", "Talent Acquisition Specialist", "Recruitment Lead", "HR Coordinator" ].sample,
    recruiter_working_start_time: Time.parse("#{rand(8..10)}:00"),
    recruiter_working_end_time: Time.parse("#{rand(17..19)}:00"),
    recruiter_status: [ 0, 1, 2 ].sample, # pending, approved, rejected
    can_manage_jobs: [ true, false ].sample,
    can_manage_applicants: [ true, false ].sample,
    can_manage_interviews: [ true, false ].sample,
    can_manage_offers: [ true, false ].sample,
    can_manage_company_profile: [ true, false ].sample,
    can_manage_recruiter_profile: [ true, false ].sample,
    can_manage_company_settings: [ true, false ].sample,
    can_manage_recruiter_settings: [ true, false ].sample,
    can_manage_company_users: [ true, false ].sample,
    can_manage_subscriptions_of_studern: [ true, false ].sample
  )
end

# ============================================================================
# USERS
# ============================================================================

puts "Creating Users..."

# Create users with Faker
20.times do |i|
  first_name = Faker::Name.first_name.gsub(/[^a-zA-Z0-9.\-#&\s]/, '')
  last_name = Faker::Name.last_name.gsub(/[^a-zA-Z0-9.\-#&\s]/, '')
  email_name = "#{first_name}#{last_name}".downcase.gsub(/[^a-z0-9]/, '')
  User.find_or_create_by!(email: "contact@#{email_name}.com") do |u|
    u.first_name = first_name
    u.last_name = last_name
    u.phone = "01#{rand(3..9)}#{rand(10000000..99999999)}"
    u.latitude = 23.7937 + rand(-0.01..0.01)
    u.longitude = 90.4066 + rand(-0.01..0.01)
    u.career_objective = Faker::Lorem.paragraph(sentence_count: 3).gsub(/[^-\x7F]/, '')
    u.dob = Date.new(rand(1990..2005), rand(1..12), rand(1..28))
    u.gender = rand(1..3)
    u.account_status = [ 0, 1, 2 ].sample # incomplete, complete, suspended
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
    start_date = Date.new(rand(2015..2020), rand(1..12), 1)
    # End date: at least 1 year after start_date, at most 2024
    min_end_year = [start_date.year + 1, 2020].max
    max_end_year = 2024
    end_year = rand(min_end_year..max_end_year)
    end_month = rand(1..12)
    end_date = Date.new(end_year, end_month, 1)
    # Ensure end_date is after start_date
    end_date = start_date.next_year if end_date <= start_date

    UserEducation.find_or_create_by!(
      user: user,
      institution_name: Faker::University.name,
      degree: [ "Bachelor's in Computer Science", "Master's in Business Administration", "Bachelor's in Engineering", "Diploma in IT" ].sample
    ) do |ue|
      ue.performance_type = rand(0..2)
      ue.performance = rand(3.0..4.0).round(2)
      ue.start_date = start_date
      ue.end_date = end_date
      ue.currently_studying = [ true, false ].sample
    end
  end
end

# ============================================================================
# USER WORK EXPERIENCES
# ============================================================================

puts "Creating User Work Experience records..."

User.all.each do |user|
  rand(1..3).times do
    # Generate a start_date between 2015 and 2021
    start_date = Date.new(rand(2015..2021), rand(1..12), 1)
    # The minimum allowed end_date
    min_end_date = Date.new(2022, 8, 1)
    # The earliest possible end_date: must be after start_date and at least min_end_date
    earliest_end_date = [start_date.next_month, min_end_date].max
    # Generate a random end_date between earliest_end_date and Dec 2024
    latest_end_date = Date.new(2024, 12, 1)
    # If earliest_end_date is after latest_end_date, set end_date = earliest_end_date
    if earliest_end_date > latest_end_date
      end_date = earliest_end_date
    else
      # Pick a random month between earliest_end_date and latest_end_date
      months_range = (earliest_end_date.year * 12 + earliest_end_date.month)..(latest_end_date.year * 12 + latest_end_date.month)
      random_month = rand(months_range)
      end_year = random_month / 12
      end_month = random_month % 12
      end_month = 1 if end_month == 0
      end_date = Date.new(end_year, end_month, 1)
    end
    # Ensure end_date is always after start_date
    if end_date <= start_date
      end_date = start_date + 1.month
    end
    
    UserWorkExperience.create!(
      user: user,
      company_name: Faker::Company.name,
      designation: Faker::Job.title,
      start_date: start_date,
      end_date: end_date,
      currently_working: [ true, false ].sample,
      job_responsibilities: Faker::Job.field,
      employment_type: rand(0..3)
    )
  end
end

# ============================================================================
# USER SKILLS
# ============================================================================

puts "Creating User Skills..."

skills = [ "Ruby on Rails", "JavaScript", "React", "Python", "Java", "PHP", "HTML CSS", "SQL", "Git", "Docker", "AWS", "Node.js", "Vue.js", "Angular", "MongoDB", "PostgreSQL", "MySQL", "Redis", "GraphQL", "REST API" ]

User.all.each do |user|
  rand(3..8).times do
    skill_name = skills.sample
    next if UserSkill.exists?(user: user, skill_name: skill_name)

    UserSkill.create!(
      user: user,
      skill_name: skill_name,
      skill_level: rand(0..3)
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
      accomplishment_name: Faker::Lorem.sentence(word_count: 3).gsub(/[^\w.\-#&\s]/, ''),
      accomplishment_description: Faker::Lorem.paragraph(sentence_count: 2).gsub(/[^\w.\-#&\s]/, ''),
      accomplishment_start_date: Date.new(rand(2020..2023), rand(1..12), 1),
      accomplishment_end_date: Date.new(rand(2023..2024), rand(1..12), 1),
      ongoing: [ true, false ].sample
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
    amount: [ 3850, 4500, 5300 ].sample,
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
recruitment_types = [ 0, 1, 2, 3 ] # job, internship, micro_job, micro_internship
work_types = [ 0, 1, 2, 3 ] # full_time, part_time, project, freelance
work_places = [ 0, 1, 2 ] # on_site, remote, hybrid
salary_types = [ 0, 1, 2, 3, 4, 5 ] # fixed, negotiable, hourly, weekly, monthly, yearly
experience_levels = [ 0, 1, 2, 3 ] # entry_level, mid_level, senior_level, expert_level
application_packages = [ 0, 1, 2 ] # basic, standard, premium
application_collection_methods = [ 0, 1, 2 ] # easy_apply, external_link, email

# Create recruitments for 2HAAS
5.times do |i|
  recruitment_type = recruitment_types.sample
  application_method = application_collection_methods.sample

  salary_type = salary_types.sample
  raw_title = [ "Senior Ruby Developer", "Frontend React Developer", "UI/UX Designer", "DevOps Engineer", "Product Manager" ].sample
  title = raw_title.gsub(/[^\w.\-#&\s]/, '')
  title = 'Job Title' if title.strip.length < 3
  # Generate a valid Bangladeshi phone number (11 digits, starts with 01)
  calling_number = "01#{rand(3..9)}#{rand(10000000..99999999).to_s.rjust(8, '0')}"
  # Generate a valid email for application_link if needed
  application_email = "apply#{rand(1000..9999)}@example.com"
  raw_description = Faker::Lorem.paragraph(sentence_count: 5)
  description = raw_description.gsub(/[^\u0000-\u007F]/, '')
  description = 'No description provided.' if description.strip.empty?
  recruitment_attrs = {
    recruitment_type: recruitment_type,
    title: title,
    description: description,
    experience_level: experience_levels.sample,
    work_type: work_types.sample,
    work_place: work_places.sample,
    latitude: 23.7937 + rand(-0.01..0.01),
    longitude: 90.4066 + rand(-0.01..0.01),
    salary_type: salary_type,
    number_of_vacancies: rand(1..5),
    application_collection_status: 1, # open
    application_collection_end_date: Date.current + rand(30..90).days,
    application_package: application_packages.sample,
    application_collection_method: application_method,
    application_link: application_method == 1 ? Faker::Internet.url : (application_method == 2 ? application_email : nil),
    calling_number: calling_number,
    company: company_2haas,
    recruiter: recruiter_abrar
  }
  if salary_type != 0
    recruitment_attrs[:annual_salary_range_start] = rand(300000..800000)
    recruitment_attrs[:annual_salary_range_end] = rand(800000..1500000)
  end
  recruitment = Recruitment.create!(recruitment_attrs)

  # Create payment for this recruitment (always create payment for 2HAAS recruitments)
  payment = create_bkash_payment("recruitment", rand(100..500))
  recruitment.update!(bkash_payment: payment)
end

# Create recruitments for Mosfism
5.times do |i|
  recruitment_type = recruitment_types.sample
  application_method = application_collection_methods.sample

  salary_type = salary_types.sample
  raw_title = [ "Creative Designer", "Marketing Specialist", "Content Writer", "SEO Expert", "Social Media Manager" ].sample
  title = raw_title.gsub(/[^\w.\-#&\s]/, '')
  title = 'Job Title' if title.strip.length < 3
  # Generate a valid Bangladeshi phone number (11 digits, starts with 01)
  calling_number = "01#{rand(3..9)}#{rand(10000000..99999999).to_s.rjust(8, '0')}"
  # Generate a valid email for application_link if needed
  application_email = "apply#{rand(1000..9999)}@example.com"
  raw_description = Faker::Lorem.paragraph(sentence_count: 5)
  description = raw_description.gsub(/[^\u0000-\u007F]/, '')
  description = 'No description provided.' if description.strip.empty?
  recruitment_attrs = {
    recruitment_type: recruitment_type,
    title: title,
    description: description,
    experience_level: experience_levels.sample,
    work_type: work_types.sample,
    work_place: work_places.sample,
    latitude: 23.7938 + rand(-0.01..0.01),
    longitude: 90.4067 + rand(-0.01..0.01),
    salary_type: salary_type,
    number_of_vacancies: rand(1..3),
    application_collection_status: 1, # open
    application_collection_end_date: Date.current + rand(30..90).days,
    application_package: application_packages.sample,
    application_collection_method: application_method,
    application_link: application_method == 1 ? Faker::Internet.url : (application_method == 2 ? application_email : nil),
    calling_number: calling_number,
    company: company_mosfism,
    recruiter: recruiter_sumaya
  }
  if salary_type != 0
    recruitment_attrs[:annual_salary_range_start] = rand(250000..600000)
    recruitment_attrs[:annual_salary_range_end] = rand(600000..1200000)
  end
  recruitment = Recruitment.create!(recruitment_attrs)

  # Create payment for this recruitment (always create payment for Mosfism recruitments)
  payment = create_bkash_payment("recruitment", rand(100..500))
  recruitment.update!(bkash_payment: payment)
end

# Create recruitments for other companies
Company.where.not(id: [ company_2haas.id, company_mosfism.id ]).each do |company|
  recruiter_permission = RecruiterPermissionsOnCompany.find_by(company: company, recruiter_status: 1) # approved
  next unless recruiter_permission

  rand(1..3).times do
    recruitment_type = recruitment_types.sample
    application_method = application_collection_methods.sample

    salary_type = salary_types.sample
    raw_title = Faker::Job.title
    title = raw_title.gsub(/[^\w.\-#&\s]/, '')
    title = 'Job Title' if title.strip.length < 3
    # Generate a valid Bangladeshi phone number (11 digits, starts with 01)
    calling_number = "01#{rand(3..9)}#{rand(10000000..99999999).to_s.rjust(8, '0')}"
    # Generate a valid email for application_link if needed
    application_email = "apply#{rand(1000..9999)}@example.com"
    raw_description = Faker::Lorem.paragraph(sentence_count: 5)
    description = raw_description.gsub(/[^\u0000-\u007F]/, '')
    description = 'No description provided.' if description.strip.empty?
    
    # Determine application status - only create open recruitments for easy_apply method
    application_status = if application_method == 0 # easy_apply
      [ 1 ].sample # only open for easy_apply
    else
      [ 0, 1, 2 ].sample # close, open, draft for other methods
    end
    
    recruitment_attrs = {
      recruitment_type: recruitment_type,
      title: title,
      description: description,
      experience_level: experience_levels.sample,
      work_type: work_types.sample,
      work_place: work_places.sample,
      latitude: 23.7937 + rand(-0.01..0.01),
      longitude: 90.4066 + rand(-0.01..0.01),
      salary_type: salary_type,
      number_of_vacancies: rand(1..4),
      application_collection_status: application_status,
      application_collection_end_date: Date.current + rand(30..90).days,
      application_package: application_packages.sample,
      application_collection_method: application_method,
      application_link: application_method == 1 ? Faker::Internet.url : (application_method == 2 ? application_email : nil),
      calling_number: calling_number,
      company: company,
      recruiter: recruiter_permission.recruiter
    }
    if salary_type != 0
      recruitment_attrs[:annual_salary_range_start] = rand(200000..800000)
      recruitment_attrs[:annual_salary_range_end] = rand(800000..1500000)
    end
    recruitment = Recruitment.create!(recruitment_attrs)

    # Create payment for this recruitment (always create payment for easy_apply or open recruitments)
    if recruitment.application_collection_method == 0 || recruitment.application_collection_status == 1 # easy_apply or open
      payment = create_bkash_payment("recruitment", rand(100..500))
      recruitment.update!(bkash_payment: payment)
    end
  end
end

# ============================================================================
# RECRUITMENT APPLIES
# ============================================================================

puts "Creating Recruitment Applications..."

# Create some applications for easy_apply recruitments that meet all criteria
Recruitment.where(application_collection_method: 0, application_collection_status: 1).each do |recruitment| # easy_apply and open
  # Only proceed if recruitment has payment and meets all criteria
  next unless recruitment.bkash_payment.present? && 
              recruitment.bkash_payment.trx_id.present? && 
              recruitment.bkash_payment.trx_status == "success"
  
  # Get users with complete profiles
  eligible_users = User.where(account_status: 1).sample(rand(1..5)) # complete

  eligible_users.each do |user|
    next if RecruitmentApply.exists?(user: user, recruitment: recruitment)

    begin
      RecruitmentApply.create!(
        user: user,
        recruitment: recruitment,
        status: [ 0, 1, 2 ].sample, # pending, accepted, rejected
        has_contacted_yet: [ true, false ].sample,
        message: [ nil, Faker::Lorem.sentence.gsub(/[^\w.\-#&\s]/, '') ].sample
      )
    rescue ActiveRecord::RecordInvalid => e
      puts "Skipping application creation for recruitment #{recruitment.id}: #{e.message}"
      next
    end
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
