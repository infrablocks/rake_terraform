# frozen_string_literal: true

require 'rake'
require 'active_support'
require 'active_support/core_ext/string/inflections'

shared_context 'with rake' do
  include Rake::DSL if defined?(Rake::DSL)

  subject { self.class.top_level_description.constantize }

  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
  end

  before do
    Rake::Task.clear
  end
end
