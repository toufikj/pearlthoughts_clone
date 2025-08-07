# 🚀 Unleash: Feature Management Overview and Setup

## 🔍 What is Unleash?

**Unleash** is an open-source feature management platform designed for implementing feature flags, progressive delivery, and A/B testing in applications. It allows you to:

- Control feature rollouts  
- Experiment safely  
- Provide targeted experiences  
- Collect feature usage metrics  

> Unleash helps decouple deployments from releases — enabling safer, faster delivery.

---

## 🧱 Core Components

- **API Server**: Manages feature toggles and exposes APIs for querying and admin.
- **Admin UI**: Web interface to configure features.
- **SDKs**: Libraries for various platforms (frontend, backend, mobile).
- **Proxy**: Middleware between clients and API for frontend/mobile security.

---

## ⚙️ How Does Unleash Work?

- **Feature Toggle**: A named flag to enable/disable functionality.
- **Activation Strategies**: Logic that determines if a feature is active.
  - Examples: `default`, `userId`, `gradualRollout`, `remoteAddress`
- **Variants**: Support for A/B testing or multiple experiences behind a toggle.

---

## 🧪 Setting Up Unleash Locally

### ✅ Prerequisites

- [Git](https://git-scm.com/)  
- [Docker](https://www.docker.com/)  
- Node.js *(optional for running source)*

---

###  Step 1: Clone and Start Unleash

```bash
git clone https://github.com/Unleash/unleash.git
cd unleash
docker-compose up -d
```

This will start the Unleash server at:

```
http://localhost:4242
```

---

### 🔐 Step 2: Access Unleash Admin UI

Open your browser at [http://localhost:4242](http://localhost:4242)  
Default credentials:

- **Username**: `admin`  
- **Password**: `unleash4all`

---

## 🏁 Creating Your First Feature Flag

1. Log in to the Admin UI  
2. Open the **Default** project  
3. Click **New feature flag**  
4. Enter a name, strategy, and description  
5. Click **Create feature flag**

---

## ⚛️ Connect a React Application to Unleash

### ✅ Prerequisites

- A working React app (Create React App or similar)
- Frontend API URL & token from your Unleash instance

---

###  Step 1: Generate a Frontend API Token

1. Go to **Admin > API Access**
2. Click **New token**
3. Select:
   - **Type**: `Frontend`
   - **Environment**: `development`
   - Copy the token and frontend URL (`http://localhost:4242/api/frontend`)

---

###  Step 2: Install the Unleash React SDK

```bash
npm install @unleash/proxy-client-react
```

---

### ⚙️ Step 3: Configure the Unleash Provider

In your React entry point (`index.js` or `App.js`):

```jsx
import React from 'react';
import { createRoot } from 'react-dom/client';
import { FlagProvider } from '@unleash/proxy-client-react';
import App from './App';

const config = {
  url: 'http://localhost:4242/api/frontend',
  clientKey: '<your-frontend-api-token>',
  appName: 'your-app-name',
  refreshInterval: 15, // seconds
};

const root = createRoot(document.getElementById('root'));

root.render(
  <React.StrictMode>
    <FlagProvider config={config}>
      <App />
    </FlagProvider>
  </React.StrictMode>
);
```

---

###  Step 4: Use Feature Flags in Components

```jsx
import { useFlag } from '@unleash/proxy-client-react';

function MyComponent() {
  const enabled = useFlag('my-feature-flag');

  return enabled ? (
    <div>New feature enabled!</div>
  ) : (
    <div>Old version</div>
  );
}
```

---

##  Additional Notes

- Use `unleash.updateContext()` to pass user info:

```js
unleash.updateContext({
  userId: 'user-123',
  properties: {
    country: 'IN',
    betaUser: 'true',
  },
});
```

- Issue separate tokens per environment (dev, staging, prod).
- Use [Unleash Edge](https://docs.getunleash.io/reference/unleash-edge) for globally distributed proxy access.

---

## 📚 References

- 🔗 [Official Docs](https://docs.getunleash.io/)
- 🐙 [GitHub Repository](https://github.com/Unleash/unleash)
- ⚛️ [React SDK Docs](https://docs.getunleash.io/reference/sdks/react)

---

## ✅ Summary

| 🔧 Task                     | ✅ Tool / Step                          |
|----------------------------|----------------------------------------|
| Run Unleash locally        | Docker or Docker Compose               |
| Access admin UI            | http://localhost:4242                  |
| Create feature flags       | Via Unleash UI                         |
| Generate frontend token    | From Admin > API Access                |
| Install SDK in React       | `@unleash/proxy-client-react`          |
| Use feature in components  | `useFlag('your-flag')`                 |
