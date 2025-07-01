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
