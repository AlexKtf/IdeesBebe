module Slugable
  extend ActiveSupport::Concern

  def to_slug
    slugged = self.instance_of?(User) ? self.username : self.name
    self.slug = slugged.parameterize
  end
end
