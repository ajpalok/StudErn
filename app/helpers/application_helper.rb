module ApplicationHelper
    # Returns the full title on a per-page basis.
    def full_title(page_title = '')
        base_title = t(:site_title, default: "StudErn")
        if page_title.empty?
            base_title
        else
            "#{page_title} | #{base_title}"
        end
    end

    # Returns the full description on a per-page basis.
    def page_description(description = "")
        base_description = t(:site_description, default: "StudErn is a platform for students to learn and earn.")
        if description.empty?
            base_description
        else
            description
        end
    end

    # def og_image(image_url = "")
    #     base_url = "/asset/img/blog-image.jpg"
    #     if image_url.empty?
    #         base_url
    #     else
    #         image_url
    #     end
    # end

    # # current language checking method
    # def current_lang
    #     I18n.locale
    # end

    # # check current page is same as parameter in nav
    # def active_header_link(active_page)
    #     # for header
    #     return "active" if current_page?(active_page)
    #     return "" if !current_page?(active_page)
    # end
    
    # # Full Name of the user
    # def full_name(user)
    #     if user.middle_name.nil? || user.middle_name.empty?
    #         middle = " "
    #     else
    #         middle = " #{user.middle_name} "
    #     end
    #     return "#{user.first_name}#{middle}#{user.last_name}"
    # end

    # Generate Gravatar URL for an user email
    def gravatar_url_for(user, options = { size: 84})
        # use case for gravatar URL by adding "gravatar_url_for(current_user, size: 250)" 
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        size = options[:size].to_i
        return "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=identicon"
    end
end
