@echo off
REM ============================================================================
REM Fix Apache Routing for Backend API
REM ============================================================================

title Fix Apache Routing
color 0A

echo.
echo ========================================
echo   FIX APACHE ROUTING
echo ========================================
echo.
echo Fixing backend .htaccess configuration...
echo.

REM Create proper .htaccess in backend root
(
echo ^<IfModule mod_rewrite.c^>
echo     RewriteEngine On
echo     
echo     # Redirect all requests to public folder
echo     RewriteRule ^^$ public/ [L]
echo     RewriteRule ^((?!public/).*)$ public/$1 [L,NC]
echo ^</IfModule^>
) > "C:\xampp\htdocs\exam-backend\.htaccess"

echo Backend root .htaccess created!
echo.

REM Create proper .htaccess in backend/public
(
echo ^<IfModule mod_rewrite.c^>
echo     ^<IfModule mod_negotiation.c^>
echo         Options -MultiViews -Indexes
echo     ^</IfModule^>
echo.
echo     RewriteEngine On
echo.
echo     # Handle Authorization Header
echo     RewriteCond %%{HTTP:Authorization} .
echo     RewriteRule .* - [E=HTTP_AUTHORIZATION:%%{HTTP:Authorization}]
echo.
echo     # Redirect Trailing Slashes If Not A Folder...
echo     RewriteCond %%{REQUEST_FILENAME} !-d
echo     RewriteCond %%{REQUEST_URI} (.+)/$
echo     RewriteRule ^ %%1 [L,R=301]
echo.
echo     # Send Requests To Front Controller...
echo     RewriteCond %%{REQUEST_FILENAME} !-d
echo     RewriteCond %%{REQUEST_FILENAME} !-f
echo     RewriteRule ^ index.php [L]
echo ^</IfModule^>
echo.
echo # Disable directory browsing
echo Options -Indexes
echo.
echo # Set default charset
echo AddDefaultCharset UTF-8
echo.
echo # Enable CORS
echo ^<IfModule mod_headers.c^>
echo     Header set Access-Control-Allow-Origin "*"
echo     Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
echo     Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
echo     Header set Access-Control-Max-Age "3600"
echo ^</IfModule^>
) > "C:\xampp\htdocs\exam-backend\public\.htaccess"

echo Backend public .htaccess created!
echo.

REM Test the backend API
echo Testing backend API...
curl -s http://192.168.11.40/exam-backend/public/api/health

echo.
echo.
echo ========================================
echo   FIX COMPLETE!
echo ========================================
echo.
echo Backend routing has been fixed!
echo.
echo Test the API manually:
echo http://192.168.11.40/exam-backend/public/api/health
echo.
pause
