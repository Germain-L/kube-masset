<?php
    // Include the database adapter which handles both MySQL and PostgreSQL connections
    require_once 'db_adapter.php';
    
    // Set default fetch mode
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
?>