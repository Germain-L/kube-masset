#!/bin/bash
set -e

# Check if migration SQL file exists
if [ ! -f "/docker-entrypoint-initdb.d/gestion_produits.sql" ]; then
    echo "Error: SQL file not found!"
    exit 1
fi

# Wait for the database to be ready
echo "Waiting for database to be ready..."
wait-for-it -t 60 "${DB_HOST:-db}:3306"

# Create a temporary initialization script
cat > /tmp/init_db.sql << EOF
-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS \`${DB_NAME:-gestiondb}\`;

-- Grant privileges to the regular user
GRANT ALL PRIVILEGES ON \`${DB_NAME:-gestiondb}\`.* TO '${REGULAR_USER:-gestionuser}'@'%';
FLUSH PRIVILEGES;
EOF

# Run initialization script
echo "Initializing database and permissions..."
mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" < /tmp/init_db.sql

# Run the migration
echo "Running database migration..."
# First create the database if it doesn't exist
echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME:-gestiondb};" | mysql -h"${DB_HOST:-db}" -u"${DB_USER:-gestionuser}" -p"${DB_PASSWORD:-devpassword}"

# Then modify the SQL file to use the correct database name
echo "Processing SQL file to use ${DB_NAME:-gestiondb} instead of gestion_produits..."
sed "s/\`gestion_produits\`/\`${DB_NAME:-gestiondb}\`/g" /docker-entrypoint-initdb.d/gestion_produits.sql > /tmp/modified_migration.sql
sed -i "s/USE \`gestion_produits\`/USE \`${DB_NAME:-gestiondb}\`/g" /tmp/modified_migration.sql

# Run the modified migration
mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" < /tmp/modified_migration.sql

# Check if migration was successful
if [ $? -eq 0 ]; then
    echo "Migration completed successfully!"
    # Grant permissions for the regular user if we're running as root
    if [ "$DB_USER" = "root" ]; then
        echo "Granting permissions to ${DB_NAME:-gestiondb} for user ${REGULAR_USER:-gestionuser}..."
        mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME:-gestiondb}\`.* TO '${REGULAR_USER:-gestionuser}'@'%';"
        mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" -e "FLUSH PRIVILEGES;"
    fi
else
    echo "Migration failed!"
    echo "Attempting fallback method with modified permissions..."
    
    # Try to create the database and grant permissions first
    echo "Creating database and granting permissions..."
    mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME:-gestiondb}\`;"
    mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME:-gestiondb}\`.* TO '${REGULAR_USER:-gestionuser}'@'%';"
    mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" -e "FLUSH PRIVILEGES;"
    
    # Try running the migration again with modified file
    echo "Retrying migration with adjusted permissions..."
    mysql -h"${DB_HOST:-db}" -u"${DB_USER:-root}" -p"${DB_PASSWORD:-rootpassword}" < /tmp/modified_migration.sql
    
    if [ $? -eq 0 ]; then
        echo "Fallback migration completed successfully!"
    else
        echo "All migration attempts failed!"
        exit 1
    fi
fi

echo "Migration process finished."
