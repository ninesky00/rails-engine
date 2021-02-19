class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.paginate(per_page, page)
    # implement to send page requested not available, per page cannot be less than 1
    limit = (per_page || 20).to_i
    records = ((page || 1).to_i - 1) * limit
    limit(limit).offset(records)
  end

  private

  def valid_page_number?(page)
    page.to_i < 1
  end

  def valid_per_page?(per_page)
    per_page.to_i < 1
  end
end
