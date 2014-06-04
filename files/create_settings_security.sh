
password=`date +%s | shasum -a 256 | base64 | head -c 32` 
master_password=`mvn --encrypt-master-password $password | grep -o '{.*}'`

echo "password=$password" > /tmp/mvnsecurity.log
echo "encrypted=$master_password" >> /tmp/mvnsecurity.log

echo "<settingsSecurity>\n<master>${master_password}</master>\n</settingsSecurity>" > ~/.m2/settings-security.xml
