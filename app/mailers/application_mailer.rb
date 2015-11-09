require "mandrill"

class ApplicationMailer < ActionMailer::Base
  default(
    from: "no-reply@#{Rails.application.config.faucet.default_url}"
  )

  private

  def send_mail(email, subject, body)
    mail(to: email, subject: subject, body: body, content_type: "text/html")
  end

  def mandrill_template(template_name, attributes)
    mandrill = Mandrill::API.new(Rails.application.config.faucet.smtp['password'])

    merge_vars = attributes.map do |key, value|
      { name: key, content: value }
    end

    mandrill.templates.render(template_name, [], merge_vars)["html"]
  end
end
