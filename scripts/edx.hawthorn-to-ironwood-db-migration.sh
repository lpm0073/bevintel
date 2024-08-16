# Install tutor 3.12.6
sudo curl -L "https://github.com/overhangio/tutor/releases/download/v3.12.6/tutor-$(uname -s)_$(uname -m)" -o /usr/local/bin/tutor
sudo chmod 0755 /usr/local/bin/tutor

# Using 3.12.6, launch ironwood instance
tutor local quickstart

# (Optionally check if ironwood is installed and launched)
# tutor local exec lms bash
# root@c9b97b959808:/openedx/edx-platform# git branch
#   * open-release/ironwood.master

# Restored database backups to mysql and mongo respectively
export LOCAL_TUTOR_DATA_DIRECTORY="$(tutor config printroot)/data/"
export LOCAL_TUTOR_MYSQL_ROOT_PASSWORD=$(tutor config printvalue MYSQL_ROOT_PASSWORD)
export LOCAL_TUTOR_MYSQL_ROOT_USERNAME=$(tutor config printvalue MYSQL_ROOT_USERNAME)

# Drop old/vanilla mysql db
docker exec -i tutor_local_mysql_1 sh -c "exec mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -e \"DROP DATABASE openedx;\""

# Restore backup
docker exec -i tutor_local_mysql_1 sh -c "exec mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD < \"/home/ubuntu/backups/mysql/mysql-data-latest.sql\""

# Copy mongodb backup
sudo cp -R /home/ubuntu/backups/mongodb/mongo-dump-latest/ $LOCAL_TUTOR_DATA_DIRECTORY/data/mongodb/backup/

# Restore mongodb backups for edxapp and cs_comments_service databases
docker exec -i tutor_local_mongodb_1 sh -c 'exec mongorestore --drop -d edxapp /data/db/backup/edxapp/'
docker exec -i tutor_local_mongodb_1 sh -c 'exec mongorestore --drop -d cs_comments_service /data/db/backup/cs_comments_service/'

# Test mysql restore
docker exec -i tutor_local_mysql_1 sh -c "exec mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -D openedx -e \"SELECT count(*) FROM auth_user;\""

# Attempt to migrate data
# $ tutor local run lms bash
# $ ./manage.py lms makemigrations
# $ ./manage.py lms migrate

tutor local run lms sh -c "./manage.py lms makemigrations"
tutor local run lms sh -c "./manage.py lms migrate"

# TODO: Now backup recently migrated data and sync to s3