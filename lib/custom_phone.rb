class CustomPhone
    # file on public\data\phone_number_validation_list.yml
    # phone_number_format = YAML.load(File.read(Rails.root.join('public', 'data', 'phone_number_validation_list.yml')))
    # CURRENTLY IMPLEMENTED FOR BANGLADESHI PHONE NUMBER

    def initialize(phone_number)
        @phone_number = phone_number
        number_purify(@phone_number) if @phone_number.present?
    end

    def isEmpty?
        @phone_number.nil? || @phone_number.empty? || @phone_number.blank?
    end

    def valid_size?
        @phone_number.length == 11
    end

    def valid_format?
        phone_number_regex = /\A01[3-9]\d{8}\z/
        phone_number_regex.match?(@phone_number)
    end

    def getFullNumber
        if @phone_number.start_with?("+") || @phone_number.start_with?("88")
            return @phone_number
        end
        "+88#{@phone_number}"
    end

    private
    def number_purify(phone_number)
        # remove all non digit character
        if phone_number.start_with?("+") || phone_number.start_with?("88")
            @phone_number = phone_number
                        .gsub(/\D/, "") # remove all non digit character
                        .gsub(/^88/, "") # remove 88 from the beginning
        else
            @phone_number = phone_number
        end
    end
end
