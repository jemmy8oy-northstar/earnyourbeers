import './App.css'
import ThemeToggle from './components/ThemeToggle'
import { ThemeProvider } from './context/ThemeContext'
import { useSession } from './api/eyv'
import SignIn from './pages/SignIn'
import Dashboard from './pages/Dashboard'

/** BEH-AUTH-1: /api/auth/me decides — a session shows the dashboard, anything else the sign-in. */
function Screen() {
  const { account, isLoading, isError, error, refetch } = useSession();

  if (isLoading) return <p className="eyv-muted eyv-center">Loading…</p>;
  if (account) return <Dashboard username={account.username} />;

  // 401 is just "not signed in"; anything else means the server could not be asked.
  const status = (error as { status?: unknown } | undefined)?.status;
  if (isError && status !== 401) {
    return (
      <div className="eyv-center">
        <p className="eyv-error" role="alert">Could not reach the server.</p>
        <button className="eyv-link" onClick={() => void refetch()}>Try again</button>
      </div>
    );
  }
  return <SignIn />;
}

function App() {
  return (
    <ThemeProvider>
      <div className="app-container">
        <div className="eyv-theme"><ThemeToggle /></div>
        <main className="eyv-main">
          <Screen />
        </main>
      </div>
    </ThemeProvider>
  )
}

export default App
