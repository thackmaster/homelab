#!/bin/bash

pg_version=$(psql --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+' | cut -d. -f1)
echo Postgres version: $pg_version
read -p "Want to upgrade Postgres? [y/N] " pg_choice

echo Stopping Mattermost...
systemctl stop mattermost

echo Checking Satellite...
satellite_status=$(subscription-manager status | grep "Overall Status:" | awk '{print $NF}') > /dev/null
if [[ "$satellite_status" == "Current" ]]; then
    echo "Satellite connection: $satellite_status"
    echo "Houston, we are a 'go' for launch!"
elif [[ "$satellite_status" == "Unknown" ]]; then
    echo "Seems we're not registered to Satellite. Registering..."
    subscription-manager register
else
    echo "Unexpected status: $satellite_status"
    exit 1
fi

## Postgres
if [[ "$pg_choice" =~ ^[Yy]$ ]]; then
    read -p "What version of Postgres do you want to upgrade to? " pg_targetversion
    echo Upgrading Postgres to $pg_targetversion...
    systemctl stop postgresql
    echo "Resetting the old Postgres version ($pg_version)..."
    dnf module reset postgresql:$pg_version/server -y > /dev/null
    echo "Installing the new Postgres version ($pg_targetversion)..."
    dnf module install postgresql:$pg_targetversion/server -y > /dev/null
    echo "Installing the Postgres upgrade tool..."
    dnf install postgresql-upgrade -y > /dev/null
    echo "Running the Postgres upgrade tool..."
    postgresql-setup --upgrade > /dev/null
    echo Setting pg_hba.conf to md5...
    awk '(/127.0.0.1\/32/ && /ident/) || (/::1\/128/ && /ident/) {gsub("ident", "md5")} {print}' /var/lib/pgsql/data/pg_hba.conf > /tmp/pg_hba.conf && mv -f /tmp/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
    echo Starting Postgres...
    systemctl start postgresql
    echo Reindexing database...
    sudo -i -u postgres psql -d mattermost -c "REINDEX DATABASE mattermost;" > /dev/null
    pg_version=$(psql --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+' | cut -d. -f1)
    echo Upgrade complete! Upgraded to Postgres $pg_version
fi

## Mattermost
$mm_dir="/opt/mattermost"
$mm_backup_dir="/opt/backups/mattermost"
cd ~
ls -l .
version=$(grep -o 'server_version=[^ ]*' $mm_dir/logs/mattermost.log | tail -1 | cut -d= -f2 | sed 's/\\":$//')
if [[ -z "$version" ]]; then
    echo "Couldn't determine version number. Please enter it manually."
    read -p "Please enter the current Mattermost version: " version
else
    echo Mattermost version: $version
fi

read -p "Please enter the Mattermost version you are upgrading to: " target_version

systemctl stop mattermost
echo Making directories...
mkdir -p $mm_backup_dir-$version
echo Copying files...
mv -f $mm_dir $mm_backup_dir-$version
cd /opt && tar zxvf ~/mattermost-$target_version-linux-amd64.tar > /dev/null
cp -rafv $mm_backup_dir-$version/mattermost/config $mm_dir > /dev/null
cp -rafv $mm_backup_dir-$version/mattermost/data $mm_dir > /dev/null
cp -rafv $mm_backup_dir-$version/mattermost/plugins $mm_dir > /dev/null
cp -rafv $mm_backup_dir-$version/mattermost/*.crt $mm_dir > /dev/null
cp -rafv $mm_backup_dir-$version/mattermost/*.key $mm_dir > /dev/null
echo Copied necessary files. Making some final changes...
cd ~
chown -R mattermost:mattermost $mm_dir
if ! setcap 'cap_net_bind_service=+ep' $mm_dir/bin/mattermost; then
    echo "Error setting the Mattermost net bind service capability. Please run `setcap 'cap_net_bind_service=+ep' $mm_dir/bin/mattermost` and start the Mattermost service manually. We did not remove backup files."
    exit 1
fi

echo Starting Mattermost...
if ! systemctl start mattermost; then
    echo Mattermost did not start correctly. Please manually start Mattermost and/or check error logs. We did not remove backup files.
else
    echo Removing backup files...
    rm -r $mm_backup_dir-$version
fi
