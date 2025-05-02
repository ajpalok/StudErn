class CustomEmail
  def initialize(email)
    # an constructor that will make a local and domain variable to store the local and domain part of the email in the class
    @local = email.split('@')[0]
    @absolute_local = email.split('@')[0].split('+')[0]
    @domain = email.split('@')[1]
  end

  def isEmpty?
    # an function that will check if the email is empty or not
    return @local.nil? || @local.empty? || @local.blank? || @domain.nil? || @domain.empty? || @domain.blank?
  end

  def actual_email
    return "#{@absolute_local}@#{@domain}"
  end

  def regected_email_local?
    return true if @local == "noreply" || @local == "no-reply"  || @local == "test" || @local == "example" || @local == "something" || @local == "anything" || @local == "nothing"
    return false
  end

  def regected_email_domain?
    # name = @domain.split('.')
    if @domain.split('.').include?("test") || @domain.split('.').include?("example") || @domain.split('.').include?("something") || @domain.split('.').include?("anything") || @domain.split('.').include?("nothing") || @domain.split('.').include?("localhost")
      return true
    end
    return false
  end

  def valid_format?
    email_regexp = /\A[a-z0-9]+(?!.*(?:\+{2,}|\-{2,}|\.{2,}))(?:[\.+\-]{0,1}[a-z0-9])*@([a-z0-9]{1,10}\.){0,3}[a-z0-9]{2,63}(\.([a-z]{1,30}[0-9]{0,10}[a-z]{1,20}[0-9]{0,10})+){1}\z/
    if email_regexp.match?(actual_email)
      return true
    end
    return false
  end
end