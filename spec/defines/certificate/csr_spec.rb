require 'spec_helper'

describe 'dehydrated::certificate::csr' do
  let(:title) { 'csr.certificate.dehydrated' }
  let(:params) do
    {
      'dn' => 'csr.certificate.dehydrated',
      'subject_alternative_names' => ['*.csr.certificate.dehydrated'],
      'algorithm' => 'secp384r1',
    }
  end

  on_supported_os.each do |os, os_facts|
    next if os_facts[:kernel] == 'windows' && !WINDOWS

    let :pre_condition do
      if %r{windows.*}.match?(os)
        'class { "dehydrated" : dehydrated_host => "some.other.host.example.com" }'
      else
        'class { "dehydrated" : dehydrated_host => $facts["fqdn"] }'
      end
    end

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
