import { createBrowserRouter } from 'react-router-dom'
import App from './App'
import InvitePage from './pages/invite/[id]'
import PrivacyPolicyPage from './pages/privacy-policy'

export const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
  },
  {
    path: "/invite/:id",
    element: <InvitePage />,
  },
  {
    path: "/privacy-policy",
    element: <PrivacyPolicyPage />,
  },
]) 