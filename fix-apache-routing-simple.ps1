# Fix Apache Routing for Backend API
Write-Host ""
Write-Host "========================================"
Write-Host "  FIX APACHE ROUTING"
Write-Host "========================================"
Write-Host ""
Write-Host "Fixing backend .htaccess configuration..."
Write-Host ""

# Create proper .htaccess in backend root
$backendRootHtaccess = @"
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Redirect all requests to public folder
    RewriteRule ^$ public/ [L]
    RewriteRule ^((?!public/).*)$ public/$1 [L,NC]
</IfModule>
"@

Set-Content -Path "C:\xampp\htdocs\exam-backend\.htaccess" -Value $backendRootHtaccess -Encoding UTF8
Write-Host "Backend root .htaccess created!"
Write-Host ""

# Create proper .htaccess in backend/public
$backendPublicHtaccess = @"
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>

# Disable directory browsing
Options -Indexes

# Set default charset
AddDefaultCharset UTF-8

# Enable CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
    Header set Access-Control-Max-Age "3600"
</IfModule>
"@

Set-Content -Path "C:\xampp\htdocs\exam-backend\public\.htaccess" -Value $backendPublicHtaccess -Encoding UTF8
Write-Host "Backend public .htaccess created!"
Write-Host ""

# Test the backend API
Write-Host "Testing backend API..."
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "SUCCESS! Backend API is responding:"
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: Backend API test failed:"
    Write-Host $_.Exception.Message
}

Write-Host ""
Write-Host "========================================"
Write-Host "  FIX COMPLETE!"
Write-Host "========================================"
Write-Host ""
Write-Host "Backend routing has been fixed!"
Write-Host ""
Write-Host "Test the API manually:"
Write-Host "http://192.168.11.40/exam-backend/public/api/health"
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
