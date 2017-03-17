require 'rake'
require 'fakefs/spec_helpers'

shared_context :rake do
  include ::Rake::DSL if defined?(::Rake::DSL)
  include ::FakeFS::SpecHelpers

  let(:rake) { Rake::Application.new }
  subject { self.class.top_level_description.constantize }

  before do
    Rake.application = rake
  end

  before(:each) do
    Rake::Task.clear
  end
end