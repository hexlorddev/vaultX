// Modal functionality
document.addEventListener('DOMContentLoaded', function () {
    // Add Credential Modal
    const addCredentialBtn = document.getElementById('addCredentialBtn');
    const addCredentialModal = document.getElementById('addCredentialModal');
    const addCredentialForm = document.getElementById('addCredentialForm');
    const closeBtns = document.querySelectorAll('.modal .close');
    
    // View Password Modal
    const viewPasswordModal = document.getElementById('viewPasswordModal');
    const credentialDetails = document.getElementById('credentialDetails');
    const copyPasswordBtn = document.getElementById('copyPasswordBtn');
    
    // Add event listeners
    if (addCredentialBtn) {
        addCredentialBtn.addEventListener('click', () => {
            addCredentialModal.style.display = 'block';
        });
    }
    
    closeBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            addCredentialModal.style.display = 'none';
            viewPasswordModal.style.display = 'none';
        });
    });
    
    // Handle add credential form
    if (addCredentialForm) {
        addCredentialForm.addEventListener('submit', function (e) {
            e.preventDefault();
            
            const service = document.getElementById('service').value;
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const url = document.getElementById('url').value;
            const notes = document.getElementById('notes').value;
            
            fetch('/add', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ service, username, password, url, notes })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Error adding credential: ' + (data.error || 'Unknown error'));
                }
            })
            .catch(error => {
                alert('Error adding credential: ' + error);
            });
        });
    }
    
    // Handle credential clicks
    document.addEventListener('click', function (e) {
        if (e.target && e.target.classList.contains('view-password')) {
            const credentialId = e.target.closest('.credential-card').dataset.id;
            
            fetch(`/credential/${credentialId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        credentialDetails.innerHTML = `
                            <p><strong>Service:</strong> ${data.credential.service}</p>
                            <p><strong>Username:</strong> ${data.credential.username}</p>
                            <p><strong>Password:</strong> <span id="passwordDisplay">${data.credential.password}</span></p>
                            ${data.credential.url ? `<p><strong>URL:</strong> <a href="${data.credential.url}" target="_blank">${data.credential.url}</a></p>` : ''}
                            ${data.credential.notes ? `<p><strong>Notes:</strong> ${data.credential.notes}</p>` : ''}
                        `;
                        viewPasswordModal.style.display = 'block';
                    } else {
                        alert('Error retrieving credential: ' + (data.error || 'Unknown error'));
                    }
                })
                .catch(error => {
                    alert('Error retrieving credential: ' + error);
                });
        }
    });
    
    // Copy password to clipboard
    if (copyPasswordBtn) {
        copyPasswordBtn.addEventListener('click', () => {
            const passwordDisplay = document.getElementById('passwordDisplay');
            const tempInput = document.createElement('input');
            tempInput.value = passwordDisplay.textContent;
            document.body.appendChild(tempInput);
            tempInput.select();
            document.execCommand('copy');
            document.body.removeChild(tempInput);
            
            copyPasswordBtn.textContent = 'Copied!';
            setTimeout(() => {
                copyPasswordBtn.textContent = 'Copy to Clipboard';
            }, 2000);
        });
    }
    
    // Search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function () {
            const query = this.value;
            if (query.length >= 2) {
                fetch(`/search?q=${encodeURIComponent(query)}`)
                    .then(response => response.text())
                    .then(html => {
                        document.getElementById('credentialsList').innerHTML = html;
                    })
                    .catch(error => {
                        console.error('Error searching:', error);
                    });
            } else if (query.length === 0) {
                // Clear search
                location.reload();
            }
        });
    }
});