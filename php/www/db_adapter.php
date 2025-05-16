<?php
// Database adapter to support both MySQL and PostgreSQL

$db_type = getenv('DB_TYPE') ?: 'mysql';
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$password = getenv('DB_PASSWORD');
$database = getenv('DB_NAME');

try {
    if ($db_type === 'postgresql') {
        // PostgreSQL connection
        $dsn = "pgsql:host=$host;dbname=$database";
        $db = new PDO($dsn, $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } else {
        // MySQL connection (default)
        $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
        $db = new PDO($dsn, $user, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    }
} catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}
