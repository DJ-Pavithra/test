// User data storage
let users = [];

// Sample user data
users = [
    {
        username: "john_doe",
        email: "john@example.com",
        password: "pass123",
        joinDate: new Date("2023-01-15")
    },
    {
        username: "jane_smith",
        email: "jane@example.com",
        password: "pass456",
        joinDate: new Date("2023-02-20")
    },
    {
        username: "admin",
        email: "admin@123.com",
        password: "admin123",
        joinDate: new Date("2023-01-01")
    }
];

// User object constructor
function User(username, email, password) {
    this.username = username;
    this.email = email;
    this.password = password;
    this.joinDate = new Date();
}

function toggleForms() {
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    loginForm.style.display = loginForm.style.display === 'none' ? 'block' : 'none';
    registerForm.style.display = registerForm.style.display === 'none' ? 'block' : 'none';
}

function registerUser(event) {
    event.preventDefault();
    
    const username = document.getElementById('regUsername').value;
    const email = document.getElementById('regEmail').value;
    const password = document.getElementById('regPassword').value;
    const confirmPassword = document.getElementById('regConfirmPassword').value;

    if (password !== confirmPassword) {
        alert('Passwords do not match!');
        return false;
    }

    if (users.some(user => user.email === email)) {
        alert('Email already registered!');
        return false;
    }

    const newUser = new User(username, email, password);
    users.push(newUser);
    alert('Registration successful!');
    toggleForms();
    return false;
}

function loginUser(event) {
    event.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;

    const user = users.find(u => u.email === email && u.password === password);
    
    if (user) {
        // Store login time in sessionStorage for admin tracking
        sessionStorage.setItem('lastLogin', JSON.stringify({
            username: user.username,
            time: new Date().toISOString()
        }));
        
        // Set login cookie
        document.cookie = `username=${user.username}; path=/`;
        
        // Redirect to dashboard
        window.location.href = 'dashboard.jsp';
    } else {
        alert('Invalid credentials!');
    }
    return false;
}
