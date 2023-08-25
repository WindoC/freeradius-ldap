#!/usr/bin/bash

. /scripts/env.sh

# radiusd user and group
sed -i "s/\tuser = freerad/\tuser = root/" $radiusdpath/radiusd.conf
sed -i "s/\tgroup = freerad/\tgroup = root/" $radiusdpath/radiusd.conf

# radiusd log
sed -i "s/\tdestination = files/\tdestination = stdout/" $radiusdpath/radiusd.conf
sed -i "s/\tauth = no/\tauth = yes/" $radiusdpath/radiusd.conf
#sed -i "s/\tauth_badpass = no/\tauth_badpass = yes/" $radiusdpath/radiusd.conf
#sed -i "s/\tauth_goodpass = no/\tauth_goodpass = yes/" $radiusdpath/radiusd.conf

## redirect log to stdout
#rm /var/log/freeradius/radius.log
#ln -s /dev/stdout /var/log/freeradius/radius.log

# # configure the default site for ldap
# sed -i -e 's/-ldap/ldap/g' $radiusdpath/sites-available/default
# sed -i -e '/^#[[:space:]]*Auth-Type LDAP {$/{N;N;s/#[[:space:]]*Auth-Type LDAP {\n#[[:space:]]*ldap\n#[[:space:]]*}/        Auth-Type LDAP {\n                ldap\n        }/}' $radiusdpath/sites-available/default
# sed -i -e 's/^#[[:space:]]*ldap/        ldap/g' $radiusdpath/sites-available/default

# # configure the inner-tunnel site for ldap
# sed -i -e 's/-ldap/ldap/g' $radiusdpath/sites-available/inner-tunnel
# sed -i -e '/^#[[:space:]]*Auth-Type LDAP {$/{N;N;s/#[[:space:]]*Auth-Type LDAP {\n#[[:space:]]*ldap\n#[[:space:]]*}/        Auth-Type LDAP {\n                ldap\n        }/}' $radiusdpath/sites-available/inner-tunnel
# sed -i -e 's/^#[[:space:]]*ldap/        ldap/g' $radiusdpath/sites-available/inner-tunnel

# remove inner-tunnel
rm $radiusdpath/sites-enabled/inner-tunnel

# copy ldap template
cp -p $radiusdpath/mods-available/ldap $radiusdpath/mods-available/ldap.bak
cp /config/ldap $radiusdpath/mods-available/ldap
ln -s $radiusdpath/mods-available/ldap $radiusdpath/mods-enabled/ldap

# set Auth-Type := ldap
cat > /root/update_authorize << EOF

    ldap

    if (ok || updated)  {
        update control {
          Auth-Type := ldap
        }
    }

EOF
sed -i -e '/^authorize {$/r /root/update_authorize' /config/default
rm /root/update_authorize

#set owner and right
chown root:root /scripts/*
chmod 600 /scripts/*
chmod 700 /scripts/*.sh
