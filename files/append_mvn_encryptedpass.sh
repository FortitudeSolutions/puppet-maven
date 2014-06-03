
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

sed -i -e "s/<password><\/password>/<password>$clean_epass<\/password>/g" ~/.m2/settings.xml



