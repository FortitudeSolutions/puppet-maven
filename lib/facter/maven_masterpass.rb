require 'facter'

Facter.add("maven_master_password") do
	setcode do
		Facter::Util::Resolution.exec('cat /tmp/mp | xargs mvn --encrypt-master-password | grep -o ^{.*}')
	end
end
