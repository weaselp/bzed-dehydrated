require 'spec_helper'

describe 'dehydrated::certificate::dh' do
  let(:title) { 'dh.certificate.dehydrated' }
  let(:params) do
    { 'dn' => 'dh.certificate.dehydrated', 'dh_param_size' => 1024 }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      next if os_facts[:kernel] == 'windows' && !WINDOWS

      let(:facts) { os_facts }

      let :pre_condition do
        if %r{windows.*}.match?(os)
          'class { "dehydrated" : dehydrated_host => "some.other.host.example.com" }'
        else
          'class { "dehydrated" : dehydrated_host => $facts["fqdn"] }'
        end
      end

      it { is_expected.to compile }
    end
  end
end
