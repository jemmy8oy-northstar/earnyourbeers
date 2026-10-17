import { useState } from 'react';
import { Button, Card, CardBody, Input } from '../components/ui';
import { errorMessage, useLoginMutation, useRegisterMutation } from '../api/eyv';

/** BEH-AUTH-1: one form, two modes. A successful call sets the session cookie and refreshes /me. */
export default function SignIn() {
  const [mode, setMode] = useState<'signin' | 'register'>('signin');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [login, loginState] = useLoginMutation();
  const [register, registerState] = useRegisterMutation();

  const registering = mode === 'register';
  const state = registering ? registerState : loginState;
  const error = state.isError ? errorMessage(state.error, registering ? 'Could not create the account.' : 'Wrong username or password.') : undefined;

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    const credentials = { username: username.trim(), password };
    void (registering ? register({ credentials }) : login({ credentials }));
  };

  const switchMode = () => {
    registerState.reset();
    loginState.reset();
    setMode(registering ? 'signin' : 'register');
  };

  return (
    <div className="eyv-narrow">
      <h1 className="eyv-title">Earn Your Beers</h1>
      <Card>
        <CardBody>
          <form className="eyv-form" onSubmit={submit} noValidate>
            <h2 className="eyv-form__heading">{registering ? 'Create an account' : 'Sign in'}</h2>
            <Input
              label="Username"
              name="username"
              autoComplete="username"
              autoCapitalize="none"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
            <Input
              label="Password"
              name="password"
              type="password"
              autoComplete={registering ? 'new-password' : 'current-password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={error}
              required
            />
            <Button type="submit" size="lg" loading={state.isLoading}>
              {registering ? 'Create account' : 'Sign in'}
            </Button>
            <Button type="button" variant="ghost" onClick={switchMode}>
              {registering ? 'I already have an account' : 'Create an account'}
            </Button>
          </form>
        </CardBody>
      </Card>
    </div>
  );
}
