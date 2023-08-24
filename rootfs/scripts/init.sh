#!/usr/bin/bash

. /scripts/env.sh

LDAP_HOST="${LDAP_HOST:-ldap1.example.com ldap2.example.com}"
LDAP_PORT="${LDAP_PORT:-389}"
LDAP_USER="${LDAP_USER:-cn=admin,dc=example,dc=com}"
LDAP_PASS="${LDAP_PASS:-password}"
LDAP_BASEDN="${LDAP_BASEDN:-dc=example,dc=com}"
LDAP_USER_BASEDN="${LDAP_USER_BASEDN:-ou=Users,dc=example,dc=com}"
LDAP_GROUP_BASEDN="${LDAP_GROUP_BASEDN:-ou=Groups,dc=example,dc=com}"
LDAP_CLIENT_BASEDN="${LDAP_CLIENT_BASEDN:-ou=Clients,dc=example,dc=com}"

LDAP_USER_ATTRIBUTE="${LDAP_USER_ATTRIBUTE:-uid}"
LDAP_MEMBERSHIP_ATTRIBUTE="${LDAP_MEMBERSHIP_ATTRIBUTE:-memberOf}"

LDAP_RADIUS_ACCESS_GROUP="${LDAP_RADIUS_ACCESS_GROUP:-}"
RADIUS_CLIENT_CREDENTIALS="${RADIUS_CLIENT_CREDENTIALS:-}"

ldap_subst() {
    sed -i -e "s/${1}/${2}/g" $radiusdpath/mods-available/ldap
}

# substitute variables into LDAP configuration file
ldap_subst "@LDAP_HOST@" "${LDAP_HOST}"
ldap_subst "@LDAP_PORT@" "${LDAP_PORT}"
ldap_subst "@LDAP_USER@" "${LDAP_USER}"
ldap_subst "@LDAP_PASS@" "${LDAP_PASS}"
ldap_subst "@LDAP_BASEDN@" "${LDAP_BASEDN}"
ldap_subst "@LDAP_USER_BASEDN@" "${LDAP_USER_BASEDN}"
ldap_subst "@LDAP_GROUP_BASEDN@" "${LDAP_GROUP_BASEDN}"
ldap_subst "@LDAP_CLIENT_BASEDN@" "${LDAP_CLIENT_BASEDN}"
ldap_subst "@LDAP_USER_ATTRIBUTE@" "${LDAP_USER_ATTRIBUTE}"
ldap_subst "@LDAP_MEMBERSHIP_ATTRIBUTE@" "${LDAP_MEMBERSHIP_ATTRIBUTE}"

# configure the LDAP group for access
if [[ -n "$LDAP_RADIUS_ACCESS_GROUP" ]]; then
    # create a temporary file with the access rules so that sed can read
    # it into the correct place in the /etc/raddb/sites-available/default file
    # WARNING: radiusd is INCREDIBLY picky about the format
    cat > /root/ldap-radius-access-group << EOF
        # only allow access to a specific LDAP group
        if (Ldap-Group == "${LDAP_RADIUS_ACCESS_GROUP}") {
            noop
        }
        else {
            reject
        }

EOF

    sed -i -e '/^post-auth {$/r /root/ldap-radius-access-group' $radiusdpath/sites-available/default
    rm /root/ldap-radius-access-group
fi

# setup clients
IFS=$',' read -ra RADIUS_CLIENT_CREDENTIALS_ARRAY <<< "$RADIUS_CLIENT_CREDENTIALS"
for i in "${RADIUS_CLIENT_CREDENTIALS_ARRAY[@]}"; do
    CLIENT="${i%%:*}"
    SECRET="${i#*:}"
    cat >> $radiusdpath/clients.conf << EOF
client $CLIENT {
    secret = $SECRET
    shortname = $CLIENT
    ipaddr = $CLIENT
    nas_type = other
}
EOF
done
