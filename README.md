Overview
Book of the Sun is a full-stack, cross-platform slot machine game inspired by classic adventure-style casino slots, featuring backend-driven game logic, free spins, expanding symbols, and secure user authentication.

The application consists of:

A Flutter frontend responsible for rendering reels, animations, user interactions, and game presentation.
A Spring Boot backend that handles authentication, slot generation, free-spin mechanics, payout calculations, and all game-critical logic.
An H2 database for user and gameplay data persistence.
The game can be deployed and run on multiple platforms from a single Flutter codebase, including:

🌐 Web
🤖 Android
🐧 Linux
🪟 Windows
To prevent client-side manipulation, every spin result and all win calculations are executed exclusively on the backend.

Supported Platforms
Thanks to Flutter's cross-platform architecture, the client application can run on:

Web
Android
Linux
Windows
The same Spring Boot backend serves all platforms through a REST API, ensuring consistent game logic and behavior regardless of the client device.
