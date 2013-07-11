class Host < ActiveRecord::Base
  has_many :jobs

  validates :name, :url, :presence => true

  def self.from_api(opts)
    opts = opts[:host] if opts[:host] # Rails' forms wraps hashes in a root tag
    host = self.find_or_initialize_by_name_and_url(:name => opts['name'], :url => opts['url'])
    host.update_status if host.valid?
    host
  end

  def url=(val)
    super(val.to_s.gsub(/\/$/, ''))
  end

  def self.with_available_slots
    all.map(&:update_status).select { |h| h.available_slots > 0 }.shuffle
  end

  def update_status
    return self if status_updated_at && status_updated_at > 10.seconds.ago

    self.available = false
    self.status_updated_at = Time.current

    if attrs = Transcoder.host_status(self)
      self.total_slots          = attrs['max_slots']
      self.available_slots      = attrs['free_slots']
      self.available            = true
    end

    save

    self
  end

end

