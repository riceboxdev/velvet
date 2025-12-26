---
description: Deploy Velvet to VPS using Dokploy
---

# Dokploy Deployment Workflow

## Prerequisites
- Dokploy installed on VPS
- GitHub repo: `riceboxdev/Velvet`
- DNS configured:
  - `api.velvetapi.com` → VPS IP
  - `app.velvetapi.com` → VPS IP

---

## Step 1: Create Project

1. Open Dokploy dashboard
2. Click **Create Project** → Name: `Velvet`

---

## Step 2: Deploy API Service

1. In project → **Create Service** → **Application**
2. Name: `api`
3. **General Tab**:
   - Provider: **GitHub**
   - Repository: `riceboxdev/Velvet`
   - Branch: `main`
   - Build Path: `./server`
   - Dockerfile: `./server/Dockerfile`

4. **Environment Tab** - Add these variables:
```env
NODE_ENV=production
PORT=3002
CORS_ORIGIN=https://app.velvetapi.com
FIREBASE_SERVICE_ACCOUNT="<minified-json-here>"
STRIPE_SECRET_KEY=sk_live_...
SENDGRID_API_KEY=SG....
EMAIL_FROM=noreply@velvetapi.com
BASE_URL=https://app.velvetapi.com
```

> **FIREBASE_SERVICE_ACCOUNT**: Wrap the JSON in double quotes. Get minified JSON:
> ```bash
> cat velvet-fc372-firebase-adminsdk-*.json | jq -c . | pbcopy
> ```

5. **Domains Tab**:
   - Add domain: `api.velvetapi.com`
   - Container Port: `3002`
   - HTTPS: ✓ (Let's Encrypt)

6. Click **Deploy**

7. **Verify**: `curl https://api.velvetapi.com/health` should return `{"status":"ok"}`

---

## Step 3: Deploy Web Service

1. In project → **Create Service** → **Application**
2. Name: `web`
3. **General Tab**:
   - Provider: **GitHub**
   - Repository: `riceboxdev/Velvet`
   - Branch: `main`
   - Build Path: `./client-nuxt`
   - Dockerfile: `./client-nuxt/Dockerfile`

4. **Environment Tab**:
```env
NODE_ENV=production
NITRO_PORT=3000
NUXT_PUBLIC_API_BASE=https://api.velvetapi.com/api
NUXT_PUBLIC_FIREBASE_API_KEY=AIzaSyCPlVZFdx2Shelx9oP1MlrKCiRro9x99bk
NUXT_PUBLIC_FIREBASE_AUTH_DOMAIN=velvet-fc372.firebaseapp.com
NUXT_PUBLIC_FIREBASE_PROJECT_ID=velvet-fc372
NUXT_PUBLIC_FIREBASE_STORAGE_BUCKET=velvet-fc372.firebasestorage.app
NUXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=836952323560
NUXT_PUBLIC_FIREBASE_APP_ID=1:836952323560:web:62eb6cb4c1a11a2911a05d
```

5. **Domains Tab**:
   - Add domain: `app.velvetapi.com`
   - Container Port: `3000`
   - HTTPS: ✓

6. Click **Deploy**

---

## Step 4: Create Test User

1. Go to [Firebase Console → Authentication](https://console.firebase.google.com/project/velvet-fc372/authentication/users)
2. Click **Add user**
3. Email: `demo@example.com`, Password: `password`

---

## Step 5: Verify

- [ ] `https://api.velvetapi.com/health` returns OK
- [ ] `https://app.velvetapi.com` loads
- [ ] Login with `demo@example.com` / `password` works

---

## Auto-Deploy (Optional)

Each service has a webhook URL in **Deployments Tab**. Add it to GitHub → Settings → Webhooks to auto-deploy on push.
