require 'spec_helper'

describe 'awstats', :type => :class do

  describe 'for osfamily RedHat' do
    it { should contain_class('awstats') }
  end

end
