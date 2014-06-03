
if [ ! -f "$1" ]; then
  echo "No file exists with the name $1"
  exit 1
elif [ ! -s "$1" ]; then
  echo "Empty file given for $1"
  exit 2
fi

pass=`cat $1`
epass=`mvn -q --encrypt-password ${pass} | egrep -o '\{.*\}'`
clean_epass=$(echo $epass | sed -e 's/\//\\\//g')

echo "pass = $pass" > /tmp/mvn.log1
echo "epass = $epass" >> /tmp/mvn.log1
echo "clean = $clean_epass" >> /tmp/mvn.log1

sed -i -e "s/<password><\/password>/<password>$clean_epass<\/password>/g" /Users/mic60076/.m2/settings.xml >> /tmp/mvn.log1

#sed -e "s/<password><\/password>/<password>$(cat $1 | xargs mvn --encrypt-password | sed 's/\//\\\//g')<\/password>/g" /Users/mic60076/.m2/settings.xml > /tmp/mvn.log1


