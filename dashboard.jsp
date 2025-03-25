<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Get welcome message and username from cookies
    String welcomeMessage = "Welcome to Study Group Finder";
    String username = "Guest";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("welcomeMessage")) {
                welcomeMessage = cookie.getValue();
            }
            if (cookie.getName().equals("username")) {
                username = cookie.getValue();
            }
        }
    }

    // User-specific visit counter
    int visits = 1;
    if (!username.equals("Guest") && cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("visitCount_" + username)) { // Unique cookie for each user
                visits = Integer.parseInt(cookie.getValue());
                visits++;
                break;
            }
        }
    }
    if (!username.equals("Guest")) {
        Cookie visitCookie = new Cookie("visitCount_" + username, String.valueOf(visits)); // Unique cookie for each user
        visitCookie.setMaxAge(60 * 60 * 24 * 30); // 30 days
        response.addCookie(visitCookie);
    }

    // Get last login info for admin
    String lastLoginInfo = (String)session.getAttribute("lastLogin");
    boolean isAdmin = session.getAttribute("isAdmin") != null && (boolean)session.getAttribute("isAdmin");
    
    // For demo purposes, set admin to true if not set
    if (session.getAttribute("isAdmin") == null) {
        isAdmin = true;
        session.setAttribute("isAdmin", true);
    }
    
    // Sample last login data for admin
    String lastLoginUsername = "admin";
    String lastLoginEmail = "admin@studygroup.com";
    String lastLoginTime = new java.util.Date().toString();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - <%= username %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --primary-foreground: #ffffff;
            --background: #f9fafb;
            --foreground: #111827;
            --muted: #6b7280;
            --muted-foreground: #6b7280;
            --border: #e5e7eb;
            --card: #ffffff;
            --card-foreground: #111827;
            --sidebar-width: 260px;
            --sidebar-collapsed-width: 70px;
            --header-height: 60px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--foreground);
            line-height: 1.5;
        }
        
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }
        
        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--card);
            border-right: 1px solid var(--border);
            height: 100vh;
            position: fixed;
            transition: width 0.3s ease;
            overflow-y: auto;
            z-index: 100;
        }
        
        .sidebar.collapsed {
            width: var(--sidebar-collapsed-width);
        }
        
        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem;
            border-bottom: 1px solid var(--border);
            height: var(--header-height);
        }
        
        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 700;
            font-size: 1.25rem;
        }
        
        .sidebar-logo i {
            font-size: 1.5rem;
        }
        
        .sidebar-toggle {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--foreground);
            width: 32px;
            height: 32px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .sidebar-toggle:hover {
            background-color: var(--background);
        }
        
        .sidebar-search {
            padding: 1rem;
            position: relative;
        }
        
        .sidebar-search input {
            width: 100%;
            padding: 0.5rem 0.5rem 0.5rem 2rem;
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            background-color: var(--background);
            font-size: 0.875rem;
        }
        
        .sidebar-search i {
            position: absolute;
            left: 1.5rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--muted);
        }
        
        .sidebar-group {
            padding: 0.5rem 0;
        }
        
        .sidebar-group-label {
            padding: 0.5rem 1rem;
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--muted);
            text-transform: uppercase;
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu-item {
            position: relative;
        }
        
        .sidebar-menu-button {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            width: 100%;
            text-align: left;
            background: none;
            border: none;
            cursor: pointer;
            color: var(--foreground);
            font-size: 0.875rem;
            border-radius: 0.375rem;
            margin: 0.125rem 0.5rem;
        }
        
        .sidebar-menu-button:hover {
            background-color: var(--background);
        }
        
        .sidebar-menu-button.active {
            background-color: var(--primary);
            color: var(--primary-foreground);
        }
        
        .sidebar-menu-button i {
            width: 16px;
            text-align: center;
        }
        
        .sidebar-menu-button span {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .sidebar.collapsed .sidebar-logo span,
        .sidebar.collapsed .sidebar-group-label,
        .sidebar.collapsed .sidebar-menu-button span,
        .sidebar.collapsed .sidebar-search {
            display: none;
        }
        
        .sidebar.collapsed .sidebar-menu-button {
            justify-content: center;
            padding: 0.5rem;
        }
        
        .sidebar-footer {
            padding: 1rem;
            border-top: 1px solid var(--border);
            margin-top: auto;
        }
        
        .create-group-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            width: 100%;
            padding: 0.5rem 1rem;
            background-color: var(--primary);
            color: var(--primary-foreground);
            border: none;
            border-radius: 0.375rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .create-group-btn:hover {
            background-color: var(--primary-hover);
        }
        
        .sidebar.collapsed .create-group-btn span {
            display: none;
        }
        
        /* Main Content Styles */
        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            transition: margin-left 0.3s ease;
            padding: 1.5rem;
        }
        
        .main-content.expanded {
            margin-left: var(--sidebar-collapsed-width);
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .header-title h1 {
            font-size: 1.875rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
        }
        
        .header-title p {
            color: var(--muted);
        }
        
        .header-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .notification-btn {
            background: none;
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }
        
        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--primary);
            color: var(--primary-foreground);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }
        
        /* Tabs */
        .tabs {
            margin-bottom: 1.5rem;
        }
        
        .tabs-list {
            display: flex;
            border-bottom: 1px solid var(--border);
            margin-bottom: 1.5rem;
        }
        
        .tab-trigger {
            padding: 0.75rem 1rem;
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            cursor: pointer;
            font-weight: 500;
            color: var(--muted);
        }
        
        .tab-trigger.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* Cards */
        .card {
            background-color: var(--card);
            border-radius: 0.5rem;
            border: 1px solid var(--border);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .card-header {
            padding: 1.25rem 1.25rem 0.5rem;
        }
        
        .card-title {
            font-weight: 600;
            font-size: 1rem;
            margin-bottom: 0.25rem;
        }
        
        .card-description {
            color: var(--muted);
            font-size: 0.875rem;
        }
        
        .card-content {
            padding: 1.25rem;
        }
        
        /* Grid Layout */
        .grid {
            display: grid;
            gap: 1rem;
        }
        
        .grid-cols-1 {
            grid-template-columns: 1fr;
        }
        
        .col-span-4 {
            grid-column: span 4;
        }
        
        .col-span-3 {
            grid-column: span 3;
        }
        
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(1, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .stats-card {
            display: flex;
            flex-direction: column;
        }
        
        .stats-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1rem 0.5rem;
        }
        
        .stats-card-title {
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .stats-card-icon {
            color: var(--muted);
        }
        
        .stats-card-content {
            padding: 0 1rem 1rem;
        }
        
        .stats-card-value {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
        }
        
        .stats-card-description {
            font-size: 0.75rem;
            color: var(--muted);
        }
        
        /* Session Items */
        .session-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.75rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .session-info {
            display: flex;
            flex-direction: column;
        }
        
        .session-name {
            font-weight: 500;
            margin-bottom: 0.25rem;
        }
        
        .session-time, .session-location {
            font-size: 0.875rem;
            color: var(--muted);
        }
        
        .session-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
            font-weight: 500;
            border-radius: 0.375rem;
            background-color: var(--background);
            border: 1px solid var(--border);
        }
        
        .members-count {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            font-size: 0.75rem;
            color: var(--muted);
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.375rem 0.75rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.375rem;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .btn-primary {
            background-color: var(--primary);
            color: var(--primary-foreground);
            border: none;
        }
        
        .btn-primary:hover {
            background-color: var(--primary-hover);
        }
        
        .btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
        }
        
        /* Progress Bars */
        .progress-container {
            margin-bottom: 1.5rem;
        }
        
        .progress-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
        }
        
        .progress-label {
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .progress-value {
            font-size: 0.875rem;
            color: var(--muted);
        }
        
        .progress-bar {
            height: 0.5rem;
            background-color: var(--background);
            border-radius: 9999px;
            overflow: hidden;
        }
        
        .progress-bar-fill {
            height: 100%;
            background-color: var(--primary);
            border-radius: 9999px;
        }
        
        /* Admin Panel */
        .admin-info {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }
        
        .admin-info-item p:first-child {
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 0.25rem;
        }
        
        .admin-info-item p:last-child {
            font-size: 0.875rem;
            color: var(--muted);
        }
        
        /* Group Cards */
        .group-card {
            height: 100%;
        }
        
        .group-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 1.25rem 1.25rem;
        }
        
        /* Resource Cards */
        .resource-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .resource-type {
            background-color: var(--primary);
            color: var(--primary-foreground);
        }
        
        .resource-date {
            font-size: 0.75rem;
            color: var(--muted);
        }
        
        /* Responsive */
        @media (min-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .grid-md-cols-2 {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (min-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(4, 1fr);
            }
            
            .grid-lg-cols-3 {
                grid-template-columns: repeat(3, 1fr);
            }
            
            .grid-lg-cols-7 {
                grid-template-columns: repeat(7, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: var(--sidebar-collapsed-width);
                transform: translateX(-100%);
            }
            
            .sidebar.mobile-open {
                transform: translateX(0);
                width: var(--sidebar-width);
            }
            
            .sidebar.mobile-open .sidebar-logo span,
            .sidebar.mobile-open .sidebar-group-label,
            .sidebar.mobile-open .sidebar-menu-button span,
            .sidebar.mobile-open .sidebar-search {
                display: block;
            }
            
            .sidebar.mobile-open .sidebar-menu-button {
                justify-content: flex-start;
                padding: 0.5rem 1rem;
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .mobile-sidebar-toggle {
                display: block;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-logo">
                    <i class="fas fa-book-open"></i>
                    <span>Study Group Finder</span>
                </div>
                <button class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
            <div class="sidebar-search">
                <i class="fas fa-search"></i>
                <input type="search" placeholder="Search groups...">
            </div>
            <div class="sidebar-group">
                <div class="sidebar-group-label">Main</div>
                <ul class="sidebar-menu">
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button active">
                            <i class="fas fa-home"></i>
                            <span>Dashboard</span>
                        </button>
                    </li>
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button">
                            <i class="fas fa-users"></i>
                            <span>My Groups</span>
                        </button>
                    </li>
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button">
                            <i class="fas fa-calendar"></i>
                            <span>Schedule</span>
                        </button>
                    </li>
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button">
                            <i class="fas fa-comment"></i>
                            <span>Messages</span>
                        </button>
                    </li>
                </ul>
            </div>
            <div class="sidebar-group">
                <div class="sidebar-group-label">Discover</div>
                <ul class="sidebar-menu">
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button">
                            <i class="fas fa-search"></i>
                            <span>Find Groups</span>
                        </button>
                    </li>
                    <li class="sidebar-menu-item">
                        <button class="sidebar-menu-button">
                            <i class="fas fa-plus-circle"></i>
                            <span>Create Group</span>
                        </button>
                    </li>
                </ul>
            </div>
            <div class="sidebar-footer">
                <button class="create-group-btn">
                    <i class="fas fa-plus-circle"></i>
                    <span>New Study Group</span>
                </button>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content" id="mainContent">
            <div class="header">
                <div class="header-title">
                    <h1><%= welcomeMessage %>, <%= username %></h1>
                    <p>Here's what's happening with your study groups today.</p>
                </div>
                <div class="header-actions">
                    <button class="notification-btn">
                        <i class="fas fa-bell"></i>
                    </button>
                    <div class="avatar">
                        <%= username.charAt(0) %>
                    </div>
                </div>
            </div>

            <div class="tabs">
                <div class="tabs-list">
                    <button class="tab-trigger active" data-tab="overview">Overview</button>
                    <button class="tab-trigger" data-tab="groups">My Groups</button>
                    <button class="tab-trigger" data-tab="schedule">Schedule</button>
                    <button class="tab-trigger" data-tab="resources">Resources</button>
                </div>

                <!-- Overview Tab -->
                <div class="tab-content active" id="overview">
                    <!-- Stats Cards -->
                    <div class="stats-grid">
                        <div class="card stats-card">
                            <div class="stats-card-header">
                                <div class="stats-card-title">Active Groups</div>
                                <div class="stats-card-icon">
                                    <i class="fas fa-users"></i>
                                </div>
                            </div>
                            <div class="stats-card-content">
                                <div class="stats-card-value">4</div>
                                <div class="stats-card-description">+2 from last week</div>
                            </div>
                        </div>
                        <div class="card stats-card">
                            <div class="stats-card-header">
                                <div class="stats-card-title">Upcoming Sessions</div>
                                <div class="stats-card-icon">
                                    <i class="fas fa-calendar"></i>
                                </div>
                            </div>
                            <div class="stats-card-content">
                                <div class="stats-card-value">7</div>
                                <div class="stats-card-description">Next session in 2 hours</div>
                            </div>
                        </div>
                        <div class="card stats-card">
                            <div class="stats-card-header">
                                <div class="stats-card-title">Study Hours</div>
                                <div class="stats-card-icon">
                                    <i class="fas fa-book-open"></i>
                                </div>
                            </div>
                            <div class="stats-card-content">
                                <div class="stats-card-value">28.5</div>
                                <div class="stats-card-description">+4.5 from last week</div>
                            </div>
                        </div>
                        <div class="card stats-card">
                            <div class="stats-card-header">
                                <div class="stats-card-title">Visit Statistics</div>
                                <div class="stats-card-icon">
                                    <i class="fas fa-search"></i>
                                </div>
                            </div>
                            <div class="stats-card-content">
                                <div class="stats-card-value"><%= visits %></div> <!-- Display user-specific visits -->
                                <div class="stats-card-description">Dashboard visits</div>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content Grid -->
                    <div class="grid grid-cols-1 grid-md-cols-2 grid-lg-cols-7">
                        <div class="card col-span-4">
                            <div class="card-header">
                                <div class="card-title">Upcoming Study Sessions</div>
                                <div class="card-description">Your scheduled sessions for this week</div>
                            </div>
                            <div class="card-content">
                                <div class="session-item">
                                    <div class="session-info">
                                        <div class="session-name">Advanced Calculus</div>
                                        <div class="session-time">Today, 4:00 PM</div>
                                    </div>
                                    <div class="session-actions">
                                        <div class="badge">Mathematics</div>
                                        <div class="members-count">
                                            <i class="fas fa-users"></i>
                                            <span>6</span>
                                        </div>
                                        <button class="btn btn-primary btn-sm">Join</button>
                                    </div>
                                </div>
                                <div class="session-item">
                                    <div class="session-info">
                                        <div class="session-name">Data Structures</div>
                                        <div class="session-time">Tomorrow, 2:30 PM</div>
                                    </div>
                                    <div class="session-actions">
                                        <div class="badge">Computer Science</div>
                                        <div class="members-count">
                                            <i class="fas fa-users"></i>
                                            <span>4</span>
                                        </div>
                                        <button class="btn btn-primary btn-sm">Join</button>
                                    </div>
                                </div>
                                <div class="session-item">
                                    <div class="session-info">
                                        <div class="session-name">Organic Chemistry</div>
                                        <div class="session-time">Wed, 5:00 PM</div>
                                    </div>
                                    <div class="session-actions">
                                        <div class="badge">Chemistry</div>
                                        <div class="members-count">
                                            <i class="fas fa-users"></i>
                                            <span>5</span>
                                        </div>
                                        <button class="btn btn-primary btn-sm">Join</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card col-span-3">
                            <div class="card-header">
                                <div class="card-title">Study Progress</div>
                                <div class="card-description">Your weekly study goals</div>
                            </div>
                            <div class="card-content">
                                <div class="progress-container">
                                    <div class="progress-header">
                                        <div class="progress-label">Mathematics</div>
                                        <div class="progress-value">75%</div>
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-bar-fill" style="width: 75%"></div>
                                    </div>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-header">
                                        <div class="progress-label">Computer Science</div>
                                        <div class="progress-value">60%</div>
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-bar-fill" style="width: 60%"></div>
                                    </div>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-header">
                                        <div class="progress-label">Chemistry</div>
                                        <div class="progress-value">45%</</div>
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-bar-fill" style="width: 45%"></div>
                                    </div>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-header">
                                        <div class="progress-label">Physics</div>
                                        <div class="progress-value">30%</div>
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-bar-fill" style="width: 30%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <% if (isAdmin) { %>
                    <!-- Admin Panel -->
                    <div class="card" style="margin-top: 1.5rem;">
                        <div class="card-header">
                            <div class="card-title">Admin Panel</div>
                            <div class="card-description">Last login activity</div>
                        </div>
                        <div class="card-content">
                            <div class="admin-info">
                                <div class="admin-info-item">
                                    <p>User</p>
                                    <p id="lastLoginUsername"><%= lastLoginUsername %></p>
                                </div>
                                <div class="admin-info-item">
                                    <p>Email</p>
                                    <p id="lastLoginEmail"><%= lastLoginEmail %></p>
                                </div>
                                <div class="admin-info-item">
                                    <p>Time</p>
                                    <p id="lastLoginTime"><%= lastLoginTime %></p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

                <!-- Groups Tab -->
                <div class="tab-content" id="groups">
                    <h2 style="font-size: 1.5rem; font-weight: 700; margin-bottom: 1rem;">My Study Groups</h2>
                    <div class="grid grid-cols-1 grid-md-cols-2 grid-lg-cols-3" style="gap: 1rem;">
                        <div class="card group-card">
                            <div class="card-header">
                                <div class="card-title">Advanced Calculus</div>
                                <div class="card-description">Group for Calculus III and beyond</div>
                            </div>
                            <div class="card-content">
                                <div class="group-card-footer">
                                    <div class="badge">Mathematics</div>
                                    <div class="members-count">
                                        <i class="fas fa-users"></i>
                                        <span>6 members</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card group-card">
                            <div class="card-header">
                                <div class="card-title">Data Structures</div>
                                <div class="card-description">Algorithms and data structures study group</div>
                            </div>
                            <div class="card-content">
                                <div class="group-card-footer">
                                    <div class="badge">Computer Science</div>
                                    <div class="members-count">
                                        <i class="fas fa-users"></i>
                                        <span>4 members</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card group-card">
                            <div class="card-header">
                                <div class="card-title">Organic Chemistry</div>
                                <div class="card-description">Focus on organic reactions and mechanisms</div>
                            </div>
                            <div class="card-content">
                                <div class="group-card-footer">
                                    <div class="badge">Chemistry</div>
                                    <div class="members-count">
                                        <i class="fas fa-users"></i>
                                        <span>5 members</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card group-card">
                            <div class="card-header">
                                <div class="card-title">Quantum Physics</div>
                                <div class="card-description">Advanced quantum mechanics concepts</div>
                            </div>
                            <div class="card-content">
                                <div class="group-card-footer">
                                    <div class="badge">Physics</div>
                                    <div class="members-count">
                                        <i class="fas fa-users"></i>
                                        <span>3 members</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Schedule Tab -->
                <div class="tab-content" id="schedule">
                    <h2 style="font-size: 1.5rem; font-weight: 700; margin-bottom: 0.5rem;">My Schedule</h2>
                    <p style="color: var(--muted); margin-bottom: 1rem;">Your upcoming study sessions and events</p>
                    <div class="card">
                        <div class="card-content">
                            <div class="session-item">
                                <div class="session-info">
                                    <div class="session-name">Advanced Calculus</div>
                                    <div class="session-time">Today, 4:00 PM - 6:00 PM</div>
                                    <div class="session-location">Online (Zoom)</div>
                                </div>
                                <div class="session-actions">
                                    <div class="badge">Mathematics</div>
                                    <button class="btn btn-primary btn-sm">Join</button>
                                </div>
                            </div>
                            <div class="session-item">
                                <div class="session-info">
                                    <div class="session-name">Data Structures</div>
                                    <div class="session-time">Tomorrow, 2:30 PM - 4:30 PM</div>
                                    <div class="session-location">Library, Room 204</div>
                                </div>
                                <div class="session-actions">
                                    <div class="badge">Computer Science</div>
                                    <button class="btn btn-primary btn-sm">Join</button>
                                </div>
                            </div>
                            <div class="session-item">
                                <div class="session-info">
                                    <div class="session-name">Organic Chemistry</div>
                                    <div class="session-time">Wed, 5:00 PM - 7:00 PM</div>
                                    <div class="session-location">Science Building, Lab 3</div>
                                </div>
                                <div class="session-actions">
                                    <div class="badge">Chemistry</div>
                                    <button class="btn btn-primary btn-sm">Join</button>
                                </div>
                            </div>
                            <div class="session-item">
                                <div class="session-info">
                                    <div class="session-name">Quantum Physics</div>
                                    <div class="session-time">Thu, 3:00 PM - 5:00 PM</div>
                                    <div class="session-location">Online (Discord)</div>
                                </div>
                                <div class="session-actions">
                                    <div class="badge">Physics</div>
                                    <button class="btn btn-primary btn-sm">Join</button>
                                </div>
                            </div>
                            <div class="session-item">
                                <div class="session-info">
                                    <div class="session-name">Group Project Meeting</div>
                                    <div class="session-time">Fri, 1:00 PM - 3:00 PM</div>
                                    <div class="session-location">Student Center</div>
                                </div>
                                <div class="session-actions">
                                    <div class="badge">Computer Science</div>
                                    <button class="btn btn-primary btn-sm">Join</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Resources Tab -->
                <div class="tab-content" id="resources">
                    <h2 style="font-size: 1.5rem; font-weight: 700; margin-bottom: 0.5rem;">Study Resources</h2>
                    <p style="color: var(--muted); margin-bottom: 1rem;">Shared resources from your study groups</p>
                    <div class="grid grid-cols-1 grid-md-cols-2 grid-lg-cols-3" style="gap: 1rem;">
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Calculus Cheat Sheet</div>
                                <div class="card-description">Advanced Calculus</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">PDF</div>
                                    <div class="resource-date">2 days ago</div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Data Structures Notes</div>
                                <div class="card-description">Data Structures</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">Document</div>
                                    <div class="resource-date">1 week ago</div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Organic Chemistry Flashcards</div>
                                <div class="card-description">Organic Chemistry</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">Link</div>
                                    <div class="resource-date">3 days ago</div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Physics Problem Set</div>
                                <div class="card-description">Quantum Physics</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">PDF</div>
                                    <div class="resource-date">Yesterday</div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Algorithm Visualization</div>
                                <div class="card-description">Data Structures</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">Link</div>
                                    <div class="resource-date">5 days ago</div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header">
                                <div class="card-title">Study Session Recording</div>
                                <div class="card-description">Advanced Calculus</div>
                            </div>
                            <div class="card-content">
                                <div class="resource-card-footer">
                                    <div class="badge resource-type">Video</div>
                                    <div class="resource-date">1 day ago</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Sidebar toggle functionality
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('mainContent');
        const sidebarToggle = document.getElementById('sidebarToggle');

        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('collapsed');
            mainContent.classList.toggle('expanded');
        });

        // Tab functionality
        const tabTriggers = document.querySelectorAll('.tab-trigger');
        const tabContents = document.querySelectorAll('.tab-content');

        tabTriggers.forEach(trigger => {
            trigger.addEventListener('click', function() {
                // Remove active class from all triggers and contents
                tabTriggers.forEach(t => t.classList.remove('active'));
                tabContents.forEach(c => c.classList.remove('active'));
                
                // Add active class to clicked trigger
                this.classList.add('active');
                
                // Show corresponding content
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Mobile sidebar functionality
        function handleResize() {
            if (window.innerWidth <= 768) {
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');
            }
        }

        window.addEventListener('resize', handleResize);
        handleResize();
    </script>
</body>
</html>