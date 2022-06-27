require 'spec_helper'

describe 'swift::ringbuilder::create' do
  let :default_params do
    {
      :part_power     => 18,
      :replicas       => 3,
      :min_part_hours => 24,
      :user           => 'swift'
    }
  end

  shared_examples 'swift::ringbuilder::create' do
    describe 'with allowed titles' do
      ['object', 'container', 'account'].each do |type|
        describe "when title is #{type}" do
          let :title do
            type
          end

          [{},
            {:part_power => 19,
            :replicas => 6,
            :min_part_hours => 2,
            :user => 'root'}].each do |param_set|

            describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
              let :param_hash do
                default_params.merge(param_set)
              end

              let :params do
                param_set
              end

              it { should contain_exec("create_#{type}").with(
                :command => "swift-ring-builder /etc/swift/#{type}.builder create #{param_hash[:part_power]} #{param_hash[:replicas]} #{param_hash[:min_part_hours]}",
                :path    =>  ['/usr/bin'],
                :user    => param_hash[:user],
                :creates => "/etc/swift/#{type}.builder",
              )}
            end
          end
        end
      end
    end

    describe 'with an invalid title' do
      let :title do
        'invalid'
      end

      it { should raise_error(Puppet::Error) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::ringbuilder::create'
    end
  end
end
