#!/usr/bin/env bash

set -e

kcadm="/opt/keycloak/bin/kcadm.sh"
common_flags=(
	'--no-config'
	'--server' 'http://localhost:8080'
)
admin_flags=(
	'--realm' 'master'
	'--user' "$KEYCLOAK_ADMIN"
	'--password' "$KEYCLOAK_ADMIN_PASSWORD"
)
realm_admin_flags=(
	'--user' 'realm-admin'
	'--password' 'admin'
)

echo "creating initial realms+users"
for realm in 'staging' 'internal'; do
	$kcadm create realms "${common_flags[@]}" "${admin_flags[@]}" -s realm=$realm -s enabled=true
	user_id="$($kcadm create users "${common_flags[@]}" "${admin_flags[@]}" --target-realm $realm -s username=realm-admin -s enabled=true --id)"
	$kcadm set-password "${common_flags[@]}" "${admin_flags[@]}" --target-realm $realm --userid $user_id --new-password admin
	$kcadm add-roles "${common_flags[@]}" "${admin_flags[@]}" --target-realm $realm --uid $user_id --cclientid realm-management --rolename realm-admin
done
