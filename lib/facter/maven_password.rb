require 'facter'

Facter.add("maven_password") do
	setcode do
		Facter::Util::Resolution.exec("cat /tmp/mp | xargs mvn --encrypt-password  | grep -o ^{.*}")
	end
end
