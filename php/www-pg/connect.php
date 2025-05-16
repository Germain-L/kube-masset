<?php
    // Get database connection details from environment variables with fallbacks
    $host = getenv('DB_HOST') ?: 'postgresql-service';
    $username = getenv('DB_USER') ?: 'gestionuser';
    $password = getenv('DB_PASSWORD') ?: 'devpassword';
    $dbname = getenv('DB_NAME') ?: 'gestiondb';

    // Connection with PDO PostgreSQL
    try {
        $db = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        
        // In PostgreSQL, column names are case-sensitive and typically lowercase
        // This function will help handle case-insensitive column names for compatibility
        function mapColumnNames($row) {
            $result = [];
            foreach ($row as $key => $value) {
                // Convert keys to uppercase to match the original MySQL column names
                $result[strtoupper($key)] = $value;
            }
            return $result;
        }
    } catch (PDOException $e) {
        die("Database connection failed: " . $e->getMessage());
    }
?>
