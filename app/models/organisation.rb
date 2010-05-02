class Organisation < ActiveRecord::Base
  has_many :clauses
  has_many :members
  
  has_many :proposals
  
  # Need to add the subclasses individually so that we can do things like:
  #   co.add_member_proposals.create(...)
  # to create a properly-scoped AddMemberProposal.
  has_many :add_member_proposals
  has_many :change_boolean_proposals
  has_many :change_text_proposals
  has_many :change_voting_period_proposals
  has_many :change_voting_system_proposals
  has_many :eject_member_proposals
  
  has_many :decisions, :through => :proposals
  
  # Given a full hostname, e.g. "myorganisation.oneclickorgs.com",
  # and assuming the installation's base domain is "oneclickorgs.com",
  # returns the organisation corresponding to the subdomain
  # "myorganisation".
  def self.find_by_host(host)
    subdomain = host.sub(Regexp.new("\.#{Setting[:base_domain]}$"), '')
    where(:subdomain => subdomain).first
  end
  
  def organisation_name
    Clause.get_text('organisation_name')
  end
  
  def objectives
    Clause.get_text('objectives')
  end
  
  def assets
    Clause.get_boolean('assets')
  end
  
  # Returns the base URL for this instance of OCO.
  # Pass the :only_host => true option to just get the host name.
  def domain(options={})
    raw_domain = clauses.get_text('domain')
    if options[:only_host]
      raw_domain.gsub(%r{^.*?://}, '').gsub(%r{/$}, '')
    else
      raw_domain
    end
  end
  
  def host
    [subdomain, Setting[:base_domain]].join('.')
  end
  
  def has_founding_member?
    Member.count > 0
  end
  
  def under_construction?
    Clause.get_text('organisation_state').nil?
  end

  def pending?
    Clause.get_text('organisation_state') == 'pending'
  end
    
  def active?
    Clause.get_text('organisation_state') == 'active'
  end
  
  def under_construction!
    clause = Clause.get_current('organisation_state')
    clause && clause.destroy    
  end
  
  def constitution
    @constitution ||= Constitution.new(self)
  end
end
