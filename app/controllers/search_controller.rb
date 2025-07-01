class SearchController < ApplicationController
  helper_method :filters_applied?

  def index
    @query = params[:q]&.strip
    @filters = extract_filters
    
    if @query.present? || filters_applied?
      @results = perform_search(@query, @filters)
    else
      @results = { recruitments: [], companies: [], users: [] }
    end
  end

  private

  def extract_filters
    {
      work_place: params[:work_place],
      work_type: params[:work_type],
      recruitment_type: params[:recruitment_type],
      experience_level: params[:experience_level],
      date_range: params[:date_range],
      salary_type: params[:salary_type],
      user_experience_level: params[:user_experience_level]
    }.compact
  end

  def filters_applied?
    @filters.values.any?(&:present?)
  end

  def perform_search(query, filters)
    # Search in recruitments first (prioritized)
    recruitments = search_recruitments(query, filters)
    
    # Search in companies
    companies = search_companies(query)
    
    # Search in users/career objectives
    users = search_users(query, filters)
    
    { recruitments: recruitments, companies: companies, users: users }
  end

  def search_recruitments(query, filters)
    base_query = Recruitment.joins(:company)
                           .where(application_collection_status: :open)
                           .includes(:company)

    # Apply text search if query present
    if query.present?
      title_matches = base_query.where("recruitments.title LIKE ?", "%#{query}%")
      company_name_matches = base_query.where("companies.name LIKE ?", "%#{query}%")
      description_matches = base_query.where("recruitments.description LIKE ?", "%#{query}%")
      
      # Combine text search results
      all_recruitments = (title_matches + company_name_matches + description_matches).uniq
    else
      all_recruitments = base_query.all
    end

    # Apply filters
    all_recruitments = apply_recruitment_filters(all_recruitments, filters)
    
    # Sort by relevance and date
    all_recruitments.sort_by do |recruitment|
      relevance_score = 0
      if query.present?
        relevance_score += 3 if recruitment.title.downcase.include?(query.downcase)
        relevance_score += 2 if recruitment.company.name.downcase.include?(query.downcase)
        relevance_score += 1 if recruitment.description.downcase.include?(query.downcase)
      end
      [-relevance_score, -recruitment.created_at.to_i] # Higher score first, then newer first
    end
  end

  def apply_recruitment_filters(recruitments, filters)
    filtered_recruitments = recruitments

    # Filter by work place
    if filters[:work_place].present?
      filtered_recruitments = filtered_recruitments.select { |r| r.work_place == filters[:work_place] }
    end

    # Filter by work type
    if filters[:work_type].present?
      filtered_recruitments = filtered_recruitments.select { |r| r.work_type == filters[:work_type] }
    end

    # Filter by recruitment type
    if filters[:recruitment_type].present?
      filtered_recruitments = filtered_recruitments.select { |r| r.recruitment_type == filters[:recruitment_type] }
    end

    # Filter by experience level
    if filters[:experience_level].present?
      filtered_recruitments = filtered_recruitments.select { |r| r.experience_level == filters[:experience_level] }
    end

    # Filter by salary type
    if filters[:salary_type].present?
      filtered_recruitments = filtered_recruitments.select { |r| r.salary_type == filters[:salary_type] }
    end

    # Filter by date range
    if filters[:date_range].present?
      filtered_recruitments = apply_date_filter(filtered_recruitments, filters[:date_range])
    end

    filtered_recruitments
  end

  def apply_date_filter(recruitments, date_range)
    case date_range
    when 'today'
      recruitments.select { |r| r.created_at.to_date == Date.current }
    when 'week'
      recruitments.select { |r| r.created_at >= 1.week.ago }
    when 'month'
      recruitments.select { |r| r.created_at >= 1.month.ago }
    when '3months'
      recruitments.select { |r| r.created_at >= 3.months.ago }
    when '6months'
      recruitments.select { |r| r.created_at >= 6.months.ago }
    when 'year'
      recruitments.select { |r| r.created_at >= 1.year.ago }
    else
      recruitments
    end
  end

  def search_companies(query)
    # Search in company names first
    name_matches = Company.where("name LIKE ?", "%#{query}%")
                         .order(created_at: :desc)
    
    # Search in company taglines
    tagline_matches = Company.where("tagline LIKE ?", "%#{query}%")
                            .order(created_at: :desc)
    
    # Search in company descriptions
    description_matches = Company.where("description LIKE ?", "%#{query}%")
                                .order(created_at: :desc)
    
    # Combine and prioritize results
    all_companies = (name_matches + tagline_matches + description_matches).uniq
    
    # Sort by relevance (name matches first, then tagline, then description)
    all_companies.sort_by do |company|
      relevance_score = 0
      relevance_score += 3 if company.name&.downcase&.include?(query.downcase)
      relevance_score += 2 if company.tagline&.downcase&.include?(query.downcase)
      relevance_score += 1 if company.description&.downcase&.include?(query.downcase)
      [-relevance_score, -company.created_at.to_i] # Higher score first, then newer first
    end
  end

  def search_users(query, filters)
    return [] unless query.present?

    # Only search users with complete profiles
    base_query = User.where(account_status: :complete)
                    .where.not(career_objective: [nil, ""])
                    .includes(:user_skills, :user_work_experiences, :user_educations)

    # Search in career objectives
    career_objective_matches = base_query.where("career_objective LIKE ?", "%#{query}%")
                                        .order(created_at: :desc)

    # Search in user skills
    skill_matches = base_query.joins(:user_skills)
                             .where("user_skills.skill_name LIKE ?", "%#{query}%")
                             .order(created_at: :desc)

    # Search in work experience
    work_matches = base_query.joins(:user_work_experiences)
                            .where("user_work_experiences.designation LIKE ? OR user_work_experiences.company_name LIKE ?", 
                                   "%#{query}%", "%#{query}%")
                            .order(created_at: :desc)

    # Search in education
    education_matches = base_query.joins(:user_educations)
                                 .where("user_educations.institution_name LIKE ? OR user_educations.degree LIKE ?", 
                                        "%#{query}%", "%#{query}%")
                                 .order(created_at: :desc)

    # Combine all user search results
    all_users = (career_objective_matches + skill_matches + work_matches + education_matches).uniq

    # Apply user-specific filters
    all_users = apply_user_filters(all_users, filters)

    # Sort by relevance
    all_users.sort_by do |user|
      relevance_score = 0
      relevance_score += 4 if user.career_objective&.downcase&.include?(query.downcase)
      relevance_score += 3 if user.user_skills.any? { |skill| skill.skill_name&.downcase&.include?(query.downcase) }
      relevance_score += 2 if user.user_work_experiences.any? { |work| work.designation&.downcase&.include?(query.downcase) }
      relevance_score += 1 if user.user_educations.any? { |edu| edu.degree&.downcase&.include?(query.downcase) }
      [-relevance_score, -user.created_at.to_i] # Higher score first, then newer first
    end
  end

  def apply_user_filters(users, filters)
    filtered_users = users

    # Filter by user experience level (based on work experience)
    if filters[:user_experience_level].present?
      filtered_users = filtered_users.select do |user|
        case filters[:user_experience_level]
        when 'entry_level'
          user.user_work_experiences.count == 0 || user.user_work_experiences.count <= 1
        when 'mid_level'
          user.user_work_experiences.count > 1 && user.user_work_experiences.count <= 3
        when 'senior_level'
          user.user_work_experiences.count > 3 && user.user_work_experiences.count <= 5
        when 'expert_level'
          user.user_work_experiences.count > 5
        else
          true
        end
      end
    end

    filtered_users
  end
end 