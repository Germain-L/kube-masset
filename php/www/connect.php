<?php
    // Get database connection details from environment variables with fallbacks
    $host = getenv('DB_HOST') ?: 'db';
    $username = getenv('DB_USER') ?: 'gestionuser';
    $password = getenv('DB_PASSWORD') ?: 'devpassword';
    $dbname = getenv('DB_NAME') ?: 'gestiondb';

    // Connexion avec pdo mysql
    try {
        $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        die("Database connection failed: " . $e->getMessage());
    }
    
?>