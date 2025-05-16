<?php
// Simple test to check if environment variables are correctly set
echo "<h1>Environment Variables Test</h1>";
echo "<p>DB_HOST: " . (getenv('DB_HOST') ?: 'Not set') . "</p>";
echo "<p>DB_USER: " . (getenv('DB_USER') ?: 'Not set') . "</p>";
echo "<p>DB_NAME: " . (getenv('DB_NAME') ?: 'Not set') . "</p>";
echo "<p>DB Connection: ";

try {
    $host = getenv('DB_HOST') ?: 'db';
    $username = getenv('DB_USER') ?: 'gestionuser';
    $password = getenv('DB_PASSWORD') ?: 'devpassword';
    $dbname = getenv('DB_NAME') ?: 'gestiondb';

    $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<span style='color:green;'>Success!</span></p>";
    
    // Get server info
    echo "<p>MySQL Server Info: " . $db->getAttribute(PDO::ATTR_SERVER_VERSION) . "</p>";
    
} catch (PDOException $e) {
    echo "<span style='color:red;'>Failed: " . $e->getMessage() . "</span></p>";
}
?>
