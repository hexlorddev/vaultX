# VaultX Password Manager

Overview
VaultX is a secure password manager that stores credentials in an encrypted database with both command-line and web interfaces. It uses AES-256 encryption to protect sensitive data and provides a user-friendly interface for managing passwords.

Features
Secure Storage: All passwords are stored with AES-256-CBC encryption
Multiple Interfaces: Command-line interface for quick access and web interface for convenient management
Password Generation: Built-in strong password generator with customizable options
User Authentication: Secure login system with password hashing using bcrypt
Search Functionality: Quickly find credentials across services and usernames
Responsive Design: Web interface works on both desktop and mobile devices
Installation
Clone the repository
Install dependencies: bundle install
Set up the database: ruby -r './lib/database' -e 'VaultXDatabase.setup'
Start the web server: ruby web/vaultx_web.rb
Usage
CLI Interface
Run ruby cli/vaultx_cli.rb to start the command-line interface
Register a new account and add credentials
Use the search and password generation features
Web Interface
Access the web interface at http://localhost:4567
Register a new account or log in
Manage credentials through the web dashboard
Use the search feature to find credentials
Generate strong passwords with the built-in generator
Security
All passwords are encrypted with AES-256-CBC
Master passwords are hashed with bcrypt
Unique IVs are used for each encryption operation
Web interface uses secure session management
Passwords are never stored in plaintext
Development
Source code: GitHub Repository
License: MIT
Maintainer: Your Name
Contributing
Contributions are welcome! Please read the contribution guidelines before submitting a pull request.

Version History
1.0.0: Initial release with CLI and web interfaces
1.1.0: Added password strength checker
1.2.0: Added export/import functionality
1.3.0: Added 2FA support for web interface
Roadmap
Cloud sync with end-to-end encryption
Mobile application
Browser extension
Advanced password auditing
Biometric authentication
Acknowledgments
Inspired by the need for secure password management
Built with Ruby, Sinatra, and OpenSSL
Special thanks to the open-source community
License
This project is licensed under the MIT License - see the LICENSE file for details.

