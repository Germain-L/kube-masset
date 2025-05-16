# Database Migration

This directory contains SQL files and scripts for initializing and migrating the database.

## Files

- `gestion_produits.sql`: Main SQL file containing the database schema and initial data.
- `migrate.sh`: Shell script that handles the migration process.

## Running Migrations

There are two ways to run migrations:

### 1. Using Docker Compose directly

```bash
docker-compose up migration
```

### 2. Using the Makefile

```bash
make dev-migrate
```

## Troubleshooting

If you encounter issues with the migration process, check the following:

1. Ensure the database container is running and accessible:
   ```bash
   docker-compose ps db
   ```

2. Check the migration container logs:
   ```bash
   docker-compose logs migration
   ```

3. Manually connect to the database to verify it's working:
   ```bash
   make dev-db-shell
   ```

## Adding New Migrations

To add new migrations:

1. Create a new SQL file in this directory with a descriptive name, e.g., `002_add_categories_table.sql`.
2. Update the migration script to include your new file.
3. Run the migrations using one of the methods described above.
