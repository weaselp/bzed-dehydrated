require 'facter'
require 'json'
require 'openssl'


puppet_vardir = Facter.value(:puppet_vardir)
configfile = File.join("#{puppet_vardir}", 'config.json')

if File.exist?(configfile) then
  config = JSON.parse(File.read(configfile))
else
  config = nil
end


Facter.add(:dehydrated_config) do
  setcode do
    config
  end
end

Facter.add(:dehydrated_domains) do
  setcode do
    puppet_vardir = Facter.value(:puppet_vardir)
    domainsfile = File.join("#{puppet_vardir}", 'domains.json')
    if File.exist?(domainsfile) then
      ret = JSON.parse(File.read(domainsfile)) 
      ret.each do |dn, dnconfig|
        base_filename = dnconfig['base_filename']
        if (config) then
          csr_dir = config["csr_dir"]
          crt_dir = config["crt_dir"]

          # CSR
          csr = File.join(csr_dir, "#{base_filename}.csr")
          if File.exists?(csr) then
            ret[dn]['csr'] = File.read(csr).strip()
          else
            ret[dn]['csr'] = ''
          end

          # CRT serial
          crt = File.join(crt_dir, "#{base_filename}.crt")
          if File.exists?(crt) then
            raw_cert = File.read(crt)
            begin
              cert = OpenSSL::X509::Certificate.new raw_cert
              crt_serial = cert.serial.to_i
            rescue OpenSSL::X509::CertificateError
              crt_serial = -1
            end
            ret[dn]['crt_serial'] = crt_serial
          else
            ret[dn]['crt_serial'] = -1
          end

          # DH mtimes
          dh = File.join(crt_dir, "#{base_filename}.dh")
          if File.exists?(dh) and File.size?(dh) then
            mtime = File.mtime(dh).to_i
            ret[dn]['dh_mtime'] = mtime
          else
            ret[dn]['dh_mtime'] = -99999999
          end
        end
      end
      ret
    else
      {}
    end
  end
end


